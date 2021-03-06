//  Created by Maksim Kalik

import Foundation

struct Venue: Decodable {
    let id: String
    let address: String?
    let name: String?
    let description: String?
    let shortDescription: String?
    let listimage: String?
    let favourite: Bool

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Id.self, forKey: .id).id
        self.address = try container.decode(String.self, forKey: .address)
        self.name = try container.decode([ValueModel].self, forKey: .name).value
        self.description = try container.decode([ValueModel].self, forKey: .description).value
        self.shortDescription = try container.decode([ValueModel].self, forKey: .shortDescription).value
        self.listimage = try container.decode(String.self, forKey: .listimage)
        self.favourite = try container.decode(Bool.self, forKey: .favourite)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case address
        case name
        case description
        case shortDescription = "short_description"
        case listimage
        case favourite
    }
    
    private struct Id: Decodable {
        let id: String
        
        private enum CodingKeys: String, CodingKey {
            case id = "$oid"
        }
    }
}

private struct ValueModel: Decodable {
    let value: String?
    let lang: String?
}

private extension Array where Element == ValueModel {
    var value: String? {
        self.filter { $0.lang == "EN" }.first?.value ?? self.first?.value
    }
}
