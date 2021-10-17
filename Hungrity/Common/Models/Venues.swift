//
//  Venues.swift
//  Hungrity
//
//  Created by Maksim Kalik on 10/17/21.
//

import Foundation

struct Venues: Decodable {
    let results: [Venue]?
    let status: Status
    
    enum Status: String, Decodable {
        case success = "OK"
        case failed = "FAILED"
    }
}
