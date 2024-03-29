//
//  APIServiceManager.swift
//  Pawple
//
//  Created by Hitesh Arora on 12/27/20.
//  Copyright © 2020 Ysabel Chen. All rights reserved.
//

import UIKit
import Alamofire

class APIServiceManager {
    static let shared = APIServiceManager()
    var totalPages: Int = 1
    var currentPage: Int = 1

    let sessionManager: Session = {
        let configuration = URLSessionConfiguration.af.default
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        let responseCacher = ResponseCacher(behavior: .modify { _, response in
            let userInfo = ["date": Date()]
            return CachedURLResponse(
                response: response.response,
                data: response.data,
                userInfo: userInfo,
                storagePolicy: .allowed)
            })

        let interceptor = GitRequestInterceptor()

        return Session(
            configuration: configuration,
            interceptor: interceptor,
            cachedResponseHandler: responseCacher,
            eventMonitors: [])
    }()

    func fetchAccessToken(completion: @escaping (Bool, String) -> Void) {
        sessionManager.request(PawpleRouter.fetchAccessToken as URLRequestConvertible)
            .responseDecodable(of: GitHubAccessToken.self) { response in
                guard let token = response.value else {
                    return completion(false, "")
                }
                TokenManager.shared.saveAccessToken(gitToken: token)
                TokenManager.shared.saveTokenExpiration(gitToken: token)
                completion(true, token.accessToken)
        }
    }

    func fetchAnimalDetails(animalId: String, completion: @escaping (AnimalDetails?) -> Void) {
        sessionManager.request(PawpleRouter.fetchAnimalDetails(animalId) as URLRequestConvertible)
            .responseDecodable(of: Animal.self) { response in
                guard let animalDetails = response.value else {
                    return completion(nil)
                }
                completion(animalDetails.animal)
        }
    }

    func searchBreeds(species: String, completion: @escaping ([Name?]) -> Void) {
        sessionManager.request(PawpleRouter.fetchListOfBreeds(species) as URLRequestConvertible)
            .responseDecodable(of: Breeds.self) { response in
                guard let animalBreedNames = response.value?.breeds else {
                    return completion([])
                }
                completion(animalBreedNames)
        }
    }

    func fetchListOfOrganizations(name: String = "", pageNumber: Int, completion: @escaping (([OrgDetails?], Pagination?) -> Void)) {

//        sessionManager.request(PawpleRouter.fetchListOfOrganizations(name, pageNumber)).responseJSON { (response) in
//            print("+++++++++++++++\(response)")
//        }
        sessionManager.request(PawpleRouter.fetchListOfOrganizations(name, pageNumber) as URLRequestConvertible).responseDecodable(of: Organization.self) { response in
            guard let orgNames = response.value?.organizations, let pagination = response.value?.pagination else {
                return completion([], nil)
            }
            completion(orgNames, pagination)
        }
    }

    func fetchOrganizationDetails(orgId: String, completion: @escaping ((OrgDetails?) -> Void)) {

        sessionManager.request(PawpleRouter.fetchOrganizationDetails(orgId) as URLRequestConvertible).responseDecodable(of: Org.self) { response in
            guard let orgDetails = response.value?.organization
                else {
                return completion(nil)
            }
            completion(orgDetails)
        }
    }

    func fetchListOfColors(species: String = "dog", completion: @escaping ((SpeciesProperties?) -> Void)) {

        sessionManager.request(PawpleRouter.fetchListOfColors(species) as URLRequestConvertible).responseDecodable(of: TypeOfSpecies.self) { response in
            guard let speciesType = response.value?.type else {
                return completion(nil)
            }
            completion(speciesType)
        }
    }
    
    func fetchResults(pageNumber: Int, completion: @escaping ([AnimalDetails?], Pagination?) -> Void) {

        sessionManager.request(PawpleRouter.fetchResults(pageNumber) as URLRequestConvertible).responseDecodable(of: Animals.self) { response in

            guard let animalsArray = response.value?.animals, let pagination = response.value?.pagination else {
                return completion([], nil)
            }
            completion(animalsArray, pagination)
        }
    }
}
