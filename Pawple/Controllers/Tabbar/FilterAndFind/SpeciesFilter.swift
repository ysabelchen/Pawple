//
//  SpeciesFilter.swift
//  Pawple
//
//  Created by Hitesh Arora on 1/17/21.
//  Copyright © 2021 Ysabel Chen. All rights reserved.
//

//Reference: https://www.petfinder.com/developers/v2/docs/#get-animals

import UIKit

enum Species: String {
    case dog
    case cat
    case none
    var description: String {
        return self.rawValue
    }
}

class SpeciesFilter: NSObject {

    static let shared = SpeciesFilter()
    var arbitaryNumber: Int = 9999
    var queryString: String = ""

    var searchFilter = [(section: String, queryName: [String], data: [String], displayName: [String], selected: [Int], multipleSelection: Bool)]()
    var selectedSpecies: Species = .none

    func returnSpecies() -> [(section: String, queryName: [String], data: [String], displayName: [String], selected: [Int], multipleSelection: Bool)] {
        switch selectedSpecies {
            case .cat:
                return catFilter()
            case .dog:
                return dogFilter()
            case .none:
                return [(section: "Species", queryName: ["type"], data: ["Dog", "Cat"], displayName: [""], selected: [arbitaryNumber], multipleSelection: false)]
        }
    }

    func catFilter() -> [(section: String, queryName: [String], data: [String], displayName: [String], selected: [Int], multipleSelection: Bool)] {
        return [(section: "Species", queryName: ["type"], data: ["Dog", "Cat"], displayName: [""], selected: [1], multipleSelection: false),
                (section: "Breed", queryName: ["breed"], data: ["Any", "🔍 Search"], displayName: [""], selected: [0], multipleSelection: true),
                (section: "Age", queryName: ["age"], data: ["Any", "Kitten", "Young", "Adult", "Senior"], displayName: [""], selected: [0], multipleSelection: true),
                (section: "Gender", queryName: ["gender"], data: ["Any", "Male", "Female"], displayName: [""], selected: [0], multipleSelection: true),
                (section: "Size", queryName: ["size"], data: ["Any", "Small (0-6 lbs)", "Medium (7-11 lbs)", "Large (12-16 lbs)", "Extra Large (> 17 lbs)"], displayName: [""], selected: [0], multipleSelection: true),
                (section: "Color", queryName: ["color"], data: ["Any", "🔍 Search"], displayName: [""], selected: [0], multipleSelection: true),
                (section: "Coat Length", queryName: ["coat"], data: ["Any", "Hairless", "Short", "Medium", "Long"], displayName: [""], selected: [0], multipleSelection: true),
                (section: "Care", queryName: ["house_trained", "declawed", "special_needs"], data: ["Any", "House-trained", "Declawed", "Special needs"], displayName: [""], selected: [0], multipleSelection: true),
                (section: "Good with", queryName: ["good_with_children", "good_with_dogs", "good_with_cats"], data: ["Any", "Kids", "Dogs", "Other cats"], displayName: [""], selected: [0], multipleSelection: true),
                (section: "Location", queryName: ["location"], data: ["Anywhere", "🔍 City or State"], displayName: [""], selected: [0], multipleSelection: true),
                (section: "Shelter/Rescue", queryName: ["organization"], data: ["Any", "🔍 Search"], displayName: ["Any", "🔍 Search"], selected: [0], multipleSelection: true),
                (section: "Pet Name", queryName: ["name"], data: ["Any", "🔍 Search"], displayName: [""], selected: [0], multipleSelection: false)]
    }

    func dogFilter() -> [(section: String, queryName: [String], data: [String], displayName: [String], selected: [Int], multipleSelection: Bool)] {
        return [(section: "Species", queryName: ["type"], data: ["Dog", "Cat"], displayName: [""], selected: [0], multipleSelection: false),
                (section: "Breed", queryName: ["breed"], data: ["Any", "🔍 Search"], displayName: [""], selected: [0], multipleSelection: true),
                (section: "Age", queryName: ["age"], data: ["Any", "Puppy", "Young", "Adult", "Senior"], displayName: [""], selected: [0], multipleSelection: true),
                (section: "Gender", queryName: ["gender"], data: ["Any", "Male", "Female"], displayName: [""], selected: [0], multipleSelection: true),
                (section: "Size", queryName: ["size"], data: ["Any", "Small (0-25 lbs)", "Medium (26-60 lbs)", "Large (61-100 lbs)", "Extra Large (> 101 lbs)"], displayName: [""], selected: [0], multipleSelection: true),
                (section: "Color", queryName: ["color"], data: ["Any", "🔍 Search"], displayName: [""], selected: [0], multipleSelection: true),
                (section: "Coat Length", queryName: ["coat"], data: ["Any", "Hairless", "Short", "Medium", "Long", "Wire", "Curly"], displayName: [""], selected: [0], multipleSelection: true),
                (section: "Care", queryName: ["house_trained", "special_needs"], data: ["Any", "House-trained", "Special needs"], displayName: [""], selected: [0], multipleSelection: true),
                (section: "Good with", queryName: ["good_with_children", "good_with_dogs", "good_with_cats"], data: ["Any", "Kids", "Other dogs", "Cats"], displayName: [""], selected: [0], multipleSelection: true),
                (section: "Location", queryName: ["location"], data: ["Anywhere", "🔍 City or State"], displayName: [""], selected: [0], multipleSelection: true),
                (section: "Shelter/Rescue", queryName: ["organization"], data: ["Any", "🔍 Search"], displayName: ["Any", "🔍 Search"], selected: [0], multipleSelection: true),
                (section: "Pet Name", queryName: ["name"], data: ["Any", "🔍 Search"], displayName: [""], selected: [0], multipleSelection: false)]
    }

    func addItemToList(array: inout [(section: String, queryName: [String], data: [String], displayName: [String], selected: [Int], multipleSelection: Bool)], name: String, displayName: String = "", index: Int) {
        if array.count >= index {
            var dataArray = array[index].data
            var displayNameArray = array[index].displayName
            var arraySelected = [Int]()

            // check if item already exist in the list.
            if !dataArray.contains(name) {
                if dataArray.count > 11 {
                    dataArray.remove(at: 10)
                    displayNameArray.remove(at: 10)
                }
                dataArray.insert(name, at: 1)
                displayNameArray.insert(displayName, at: 1)
                array[index].data = dataArray
                array[index].displayName = displayNameArray
            } else {
                // if the name already exists, then delete it - maybe?
                //find at what index the name exists before we remove it.
                if let indexToDelete = dataArray.firstIndex(of: name) {                    dataArray.remove(at: indexToDelete)
                    if displayNameArray.count > indexToDelete {
                        displayNameArray.remove(at: indexToDelete)
                    }
                    array[index].data = dataArray
                    array[index].displayName = displayNameArray
                }
            }

            if array[index].data.count > 2 {
                array[index].selected = []
                for indx in 0...array[index].data.count-3 {
                    arraySelected.append(indx+1)
                }
                array[index].selected = arraySelected
            } else {
                array[index].selected = [0]
            }
        }
    }

    func addLocationToArray(array: inout [(section: String, queryName: [String], data: [String], displayName: [String], selected: [Int], multipleSelection: Bool)], name: String, index: Int, isMilesSelected: Bool = false) {

        if array.count >= index {
            var dataArray = array[index].data

            // check if item already exist in the list.
            if !dataArray.contains(name) {
                if isMilesSelected {
                    if dataArray.count > 3 {
                        dataArray.remove(at: 2)
                    }
                    dataArray.insert(name, at: 2)
                    array[index].data = dataArray
                    array[index].selected = [1, 2]
                } else {
                    if dataArray.count > 3 {
                        dataArray.remove(at: 1)
                    }
                    dataArray.insert(name, at: 1)
                    array[index].data = dataArray
                    array[index].selected = [1]
                }
            }
        }
    }

    func createSearchQuery(array: [(section: String, queryName: [String], data: [String], displayName: [String], selected: [Int], multipleSelection: Bool)]) {

        self.queryString = "animals?"
        for index in array {

            if (index.data[index.selected.first ?? 0]).contains("Any") {
                continue
            }

            if index.queryName.first == "location" {
                if let location = index.data[1] as? String {
                    self.queryString.append("location=\(location)&")
                }
                if let miles = index.data[2] as? String {
                    self.queryString.append("distance=\(miles[7..<miles.count-6])&")
                }
            } else if index.multipleSelection {
                if index.queryName.count >= index.selected.count && index.queryName.count > 1 {
                    for item in index.selected {
                        if item != 0 {
                            self.queryString.append("\(index.queryName[item-1])=true&")
                        }
                    }
                } else {
                    var concatenatedString = ""
                    for item in index.selected {
                        if item != 0 {
                            concatenatedString.append("\(returnKeyName(searchKey: index.data[item])),")
                        }
                    }
                    self.queryString.append("\(index.queryName.first!)=\(concatenatedString)&")
                }

            } else {
                self.queryString.append("\(index.queryName.first!)=\(index.data[index.selected.first ?? 0])&")
            }
        }
        self.queryString.append("status=adoptable")
        print("++++++++++++++++\(queryString)")
    }
}


func returnKeyName (searchKey: String) -> String {

    if searchKey.contains("Small") {
        return "small"
    } else if searchKey.contains("Medium") {
        return "medium"
    } else if searchKey.contains("Extra Large") {
        return "xlarge"
    } else if searchKey.contains("Large") {
        return "large"
    } else if searchKey.contains("Puppy") {
        return "baby"
    }
    return searchKey
}

extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        let end = index(start, offsetBy: min(self.count - range.lowerBound,
                                             range.upperBound - range.lowerBound))
        return String(self[start..<end])
    }

    subscript(_ range: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        return String(self[start...])
    }
}
