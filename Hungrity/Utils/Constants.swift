//
//  Constants.swift
//  Hungrity
//
//  Created by Maksim Kalik on 10/16/21.
//

import Foundation

struct Constants {
    static let basehost = "restaurant-api.wolt.fi"
    static let basepath = "/v3/venues"
    
    static let venueCellIdentifier = "VenueTableViewCell"
}

struct Configuration {
    static let refreshDeadlineSeconds: Double = 10
    static let maxVenuesItems = 15
}
