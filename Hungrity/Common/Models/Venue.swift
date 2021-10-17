//
//  VenueModel.swift
//  Hungrity
//
//  Created by Maksim Kalik on 10/17/21.
//

import Foundation

struct Venue: Decodable {
    let id: String
    let address: String
    let name: String?
    let description: String?
    let shortDescription: String?
    let listimage: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(ActiveMenu.self, forKey: .acitveMenu).id
        self.address = try container.decode(String.self, forKey: .address)
        self.name = try container.decode(ValueModel.self, forKey: .name).value
        self.description = try container.decode(ValueModel.self, forKey: .description).value
        self.shortDescription = try container.decode(ValueModel.self, forKey: .shortDescription).value
        self.listimage = try container.decode(String.self, forKey: .listimage)
    }
    
    private enum CodingKeys: String, CodingKey {
        case acitveMenu = "active_menu"
        case address
        case name
        case description
        case shortDescription = "short_description"
        case listimage
    }
    
    private struct ValueModel: Decodable {
        let value: String?

        private struct ValueElement: Decodable {
            let value: String?
        }

        init(from decoder: Decoder) throws {
            var container = try decoder.unkeyedContainer()
            self.value = try container.decode(ValueElement.self).value
        }
    }
    
    private struct ActiveMenu: Decodable {
        let id: String
        
        private enum CodingKeys: String, CodingKey {
            case id = "$oid"
        }
    }
}
