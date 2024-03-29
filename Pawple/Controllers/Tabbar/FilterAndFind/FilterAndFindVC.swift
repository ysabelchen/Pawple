//
//  FilterAndFindVC.swift
//  Pawple
//
//  Created by Hitesh Arora on 12/13/20.
//  Copyright © 2020 Ysabel Chen. All rights reserved.
//

import UIKit

class FilterAndFindVC: UIViewController {

    var selectedSection: Int = 0
    var searchFilter = [(section: String, queryName: [String], data: [String], displayName: [String], selected: [Int], multipleSelection: Bool)]()
    let purpleColor = UIColor(red: 172/255.0, green: 111/255.0, blue: 234/255.0, alpha: 1.0)
    
    @IBOutlet weak var collectionViewFilter: UICollectionView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.resetFiltersAction()
        // Header View
        if let flowLayout = self.collectionViewFilter.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.sectionHeadersPinToVisibleBounds = true
            flowLayout.sectionFootersPinToVisibleBounds = true
        }
        
        APIServiceManager.shared.fetchAccessToken { (isSuccess, _) in
            if !isSuccess {
                print("Error fetching Access Token")
            }
        }
    }
    
    @IBAction func resetFiltersAction() {
        SpeciesFilter.shared.selectedSpecies = .none
        self.searchFilter = SpeciesFilter.shared.returnSpecies()
        self.collectionViewFilter.reloadData()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchLocationTableViewController" {
            if let objVC = segue.destination as? SearchLocationTableViewController {
                objVC.selectedIndex = selectedSection
                objVC.arrayFilter = self.searchFilter
            }
        } else if segue.identifier == "SearchTableViewController" {
            if let objVC = segue.destination as? SearchTableViewController {
                objVC.selectedIndex = selectedSection
                objVC.arrayFilter = self.searchFilter
            }
        } else if segue.identifier == "goToResults" {
            if segue.destination is ResultsCollectionVC {
                let searchQuery = SpeciesFilter.shared.createSearchQuery(array: self.searchFilter)
            }
        }
    }

    func getPetName(indexPath: IndexPath) {
        var inputTextField: UITextField?

        let alert = UIAlertController(title: nil, message: "Please Enter A \(SpeciesFilter.shared.selectedSpecies.description.capitalized) Name", preferredStyle: .alert)
        alert.addTextField { (textfield) in
            inputTextField = textfield
        }
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { (_) in
            if (inputTextField?.text?.count)! > 0 {
                SpeciesFilter.shared.addItemToList(array: &self.searchFilter, name: inputTextField!.text!.capitalized, displayName: inputTextField!.text!.capitalized, index: indexPath.section)
                self.collectionViewFilter.reloadSections(IndexSet(integer: indexPath.section))
            }
        }))
        self.present(alert, animated: true)
    }

    func getDisplayName(indexPath: IndexPath, isOrgNameRequired: Bool = false) -> String {
        var displayName = self.searchFilter[indexPath.section].data[indexPath.item]

        // we are getting the organization section
        if isOrgNameRequired && (indexPath.section == self.searchFilter.count - 2) {
            displayName = self.searchFilter[indexPath.section].displayName[indexPath.item]
        }
        return displayName
    }

    func removeItemFromSelection (indexPath: IndexPath) {

        let selectedItem = self.getDisplayName(indexPath: indexPath)
        if (indexPath.section == 1 || indexPath.section == 5 || indexPath.section == 10) {
            SpeciesFilter.shared.addItemToList(array: &self.searchFilter, name: selectedItem, displayName: "", index: indexPath.section)
        }
    }
}

extension FilterAndFindVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.searchFilter.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.searchFilter[section].data.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {

        guard kind == UICollectionView.elementKindSectionHeader else {
            if let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FilterCollectionFooterView", for: indexPath) as? FilterCollectionFooterView {
                return footerView
            }
            return UICollectionReusableView()
        }
        if let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FilterCollectionHeaderView", for: indexPath) as? FilterCollectionHeaderView {
            headerView.title.text = self.searchFilter[indexPath.section].section
            return headerView
        }
        return UICollectionReusableView()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ofType: FilterViewCell.self, for: indexPath)

        cell.labelFilterName.text = self.getDisplayName(indexPath: indexPath, isOrgNameRequired: true)

        let isCellSelected =  self.searchFilter[indexPath.section].selected.contains(indexPath.item)

        if isCellSelected {
            cell.labelFilterName.textColor = .purple
            cell.layer.borderColor = UIColor.purple.cgColor
            cell.layer.borderWidth = 3
            
        } else {
            cell.labelFilterName.textColor = .darkGray
            cell.layer.borderColor = UIColor.darkGray.cgColor
            cell.layer.borderWidth = 1.5
        }
        
        cell.layer.cornerRadius = 8
        cell.tag = indexPath.row
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        // if item contains search text
        if self.searchFilter[indexPath.section].data[indexPath.item].contains("City or State") {
            self.selectedSection = indexPath.section
            self.performSegue(withIdentifier: "SearchLocationTableViewController", sender: self)
        } else if self.searchFilter[indexPath.section].data[indexPath.item].contains("Search") {
            self.selectedSection = indexPath.section

            if self.searchFilter[indexPath.section].section == "Pet Name" {
                self.getPetName(indexPath: indexPath)
            } else {
                self.performSegue(withIdentifier: "SearchTableViewController", sender: self)
            }
        } else {
            // Check for Species
            if indexPath.section == 0 {
                SpeciesFilter.shared.selectedSpecies = indexPath.item == 0 ? Species.dog : Species.cat
                self.searchFilter = SpeciesFilter.shared.returnSpecies()
                self.collectionViewFilter.reloadData()
            } else {
                if self.searchFilter[indexPath.section].multipleSelection == true {
                    var array = self.searchFilter[indexPath.section].selected
                    // If first item (Any) is selected, we will just select that item
                    if indexPath.item == 0 {
                        array = [indexPath.item]
                    } else if array.contains(indexPath.item) {
                        // removing element from selected list if user tap on the selected item.
                        if let index = array.firstIndex(of: indexPath.item) {
                            self.removeItemFromSelection(indexPath: indexPath)
                            array.remove(at: index)
                        }
                        array = array.count == 0 ? [0] : array
                    } else if !array.contains(indexPath.item) {
                        if let index = array.firstIndex(of: 0) {
                            self.removeItemFromSelection(indexPath: indexPath)
                            array.remove(at: index)
                        }
                        array.append(indexPath.item)
                        // If user selects every data element, we are defaulting it to Any
                        if array.count == self.searchFilter[indexPath.section].data.count - 1 {
                            array = [0]
                        }
                    }


if (indexPath.section != 1 && indexPath.section != 5 && indexPath.section != 10) {                              self.searchFilter[indexPath.section].selected = array
                    }
                } else {
                    self.searchFilter[indexPath.section].selected = [indexPath.item]
                }
            }
            self.collectionViewFilter.reloadSections(IndexSet(integer: indexPath.section))
        }
    }
}

extension FilterAndFindVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 40)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        let arrayFilterCount = self.searchFilter.count
        if arrayFilterCount > 1 && section == arrayFilterCount - 1 {
            return CGSize(width: collectionView.bounds.size.width, height: 70)
        }
        return CGSize(width: collectionView.bounds.size.width, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        
        let totalCellWidth = Int(collectionView.layer.frame.size.width) / 3 * collectionView.numberOfItems(inSection: 0)
        let totalSpacingWidth = (collectionView.numberOfItems(inSection: section) - 1)
        
        let leftInset = (collectionView.layer.frame.size.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        //        let rightInset = leftInset
        
        return UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
    }
}


extension UIColor {
    static let selectedbackgroundFilterColor = UIColor(red: 121/255, green: 22/255, blue: 211/255, alpha: 1.0)
    static let deSelectedFilterTextColor = UIColor(red: 121/255, green: 22/255, blue: 211/255, alpha: 1.0)
}

extension CGColor {
    static let selectedBorderFilterColor = UIColor(red: 121/255, green: 22/255, blue: 211/255, alpha: 1.0).cgColor
}
