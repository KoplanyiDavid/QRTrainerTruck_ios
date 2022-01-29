//
//  Post.swift
//  QRTrainerTruck
//
//  Created by Koplányi Dávid on 2021. 11. 06..
//

import Foundation

struct Post: Codable {
    
    let authorId: String
    let authorName: String
    let imageUrl: URL
    let title: String
    let description: String
    let sorter: UInt64
    
    enum CodingKeys: String, CodingKey {
        case authorId
        case authorName
        case description
        case imageUrl
        case title
        case sorter
    }
}
