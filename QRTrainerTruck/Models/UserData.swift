//
//  User.swift
//  QRTrainerTruck
//
//  Created by Koplányi Dávid on 2021. 11. 09..
//

import Foundation

struct UserData: Codable {
    
    let acceptedtermsandcons: String
    let email: String
    let id: String
    let mobile: String
    let name: String
    let profilePictureUrl: String
    let rank: String
    let score: UInt8
    let trainings: [Training]
    
    enum CodingKeys: String, CodingKey {
        case acceptedtermsandcons
        case email
        case id
        case mobile
        case name
        case profilePictureUrl
        case rank
        case score
        case trainings
    }
}
