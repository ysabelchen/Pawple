//
//  Animals.swift
//  Pawple
//
//  Created by 22ysabelc on 11/29/20.
//  Copyright © 2020 Ysabel Chen. All rights reserved.
//

import Foundation

class Animals: NSObject, Decodable {
    var animals: [AnimalDetails?]
}

class AnimalDetails: NSObject, Decodable {
    var id: Int64
    var organization_id: String?
    var name: String?
    var type: String?
    var breeds: AnimalBreeds?
    var organization: Organization?
    var gender: String?
    var size: String?
    var coat: String?
    var colors: Colors?
    var age: String?
    var photos: [AnimalPhotos?]
    var status: String?
    // TODO: add attributes and environment
}

class AnimalBreeds: NSObject, Decodable {
    var primary: String?
    var secondary: String?
    var mixed: Bool?
    var unknown: Bool?
}

class AnimalPhotos: NSObject, Decodable {
    var small: String?
    var medium: String?
    var large: String?
    var full: String?
}

class Organization: NSObject, Decodable {
    var organizations: [OrgDetails?]
}

class OrgDetails: NSObject, Decodable {
    var email: String?
    var name: String?
    var phone: String?
    var address: OrgAddress?
}

class OrgAddress: NSObject, Decodable {
    var address1: String?
    var address2: String?
    var city: String?
    var state: String?
    var postcode: String?
    var country: String?
}

class TypeOfSpecies: NSObject, Decodable {
    var type: SpeciesProperties?
}

class SpeciesProperties: NSObject, Decodable {
    var name: String?
    var coats: [String]
    var colors: [String]
    var genders: [String]
}
class Colors: NSObject, Decodable {
    var primary: String?
    var secondary: String?
    var tertiary: String?
}
