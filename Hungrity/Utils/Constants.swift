//  Created by Maksim Kalik

import Foundation

struct Constants {
    static let basehost = "restaurant-api.wolt.fi"
    static let basepath = "/v3/venues"
    
    static let venueCellIdentifier = "VenueTableViewCell"
    static let coordinates: [(lat: Double, lon: Double)] = [
        (60.170187, 24.930599),
        (60.169418, 24.931618),
        (60.169818, 24.932906),
        (60.170005, 24.935105),
        (60.169108, 24.936210),
        (60.168355, 24.934869),
        (60.167560, 24.932562),
        (60.168254, 24.931532),
        (60.169012, 24.930341),
        (60.170085, 24.929569)
    ]
}

struct Configuration {
    static let refreshDeadlineSeconds: Double = 10
    static let maxVenuesItems = 15
}

enum BaseIcon: String {
    case favoriteSelected = "favorite_filled"
    case favoriteNotSelected = "favorite_border"
}
