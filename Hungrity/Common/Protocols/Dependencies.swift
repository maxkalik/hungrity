//
//  Dependencies.swift
//  Hungrity
//
//  Created by Maksim Kalik on 10/18/21.
//

import Foundation

protocol Dependencies:
    HasLocation,
    HasVenues {
}

// MARK: - Dependencies protocols

protocol HasLocation: AnyObject {
    var locationService: LocationServiceProtocol { get set }
}

protocol HasVenues: AnyObject {
    var venuesService: VenuesServiceProtocol { get set }
}

// MARK: - SDKDependencies

final class AppDependencies: Dependencies {

    lazy var locationService: LocationServiceProtocol = LocationService()
    lazy var venuesService: VenuesServiceProtocol = VenuesService()
}
