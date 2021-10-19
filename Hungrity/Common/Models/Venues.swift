//  Created by Maksim Kalik

import Foundation

struct Venues: Decodable {
    let results: [Venue]?
    let status: Status
    
    enum Status: String, Decodable {
        case success = "OK"
        case failed = "FAILED"
    }
}
