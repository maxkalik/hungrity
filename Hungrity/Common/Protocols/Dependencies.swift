//  Created by Maksim Kalik

import Foundation

protocol Dependencies:
    HasLocation,
    HasVenues,
    HasLocalStorage {
}

// MARK: - Dependencies protocols

protocol HasLocation: AnyObject {
    var locationService: LocationServiceProtocol { get set }
}

protocol HasVenues: AnyObject {
    var venuesService: VenuesServiceProtocol { get set }
}

protocol HasLocalStorage: AnyObject {
    var localStorage: LocalStorageProtocol { get set }
}

// MARK: - SDKDependencies

final class AppDependencies: Dependencies {

    lazy var locationService: LocationServiceProtocol = LocationService()
    lazy var venuesService: VenuesServiceProtocol = VenuesService()
    lazy var localStorage: LocalStorageProtocol = LocalStorage()
}
