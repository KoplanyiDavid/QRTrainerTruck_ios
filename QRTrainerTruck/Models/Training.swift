//
//  Training.swift
//  QRTrainerTruck
//
//  Created by Koplányi Dávid on 2021. 11. 06..
//

import Foundation

struct Training: Codable {
    
    //let id: String
    let trainer: String
    let date: String
    let location: String
    let title: String
    let sorter: UInt64
    let trainees: Array<String>
    
    enum CodingKeys: String, CodingKey {
        //case id
        case trainer
        case date
        case location
        case title
        case sorter
        case trainees
    }
}
