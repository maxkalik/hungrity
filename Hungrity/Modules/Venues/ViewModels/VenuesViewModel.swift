//  Created by Maksim Kalik

import Foundation
import Combine
import CoreLocation
import UIKit

protocol VenuesViewModelViewDelegate: AnyObject {
    func startLoading()
    func finishLoading()
    func showCenteredMessage(_ msg: String)
}

protocol VenuesViewModel {
    var viewDelegate: VenuesViewModelViewDelegate? { get set }
    var venuesCount: Int { get }
    var venues: [VenueCellViewModel] { get }
    var favoritesButtonImageName: BaseIcon { get }

    func viewDidLoad()
    func startRefreshing()
    func favoritesDidPress()
}

extension VenuesViewModel {
    var title: String {
        "Hungrity"
    }
}

// MARK: - View Model Implementation

final class VenuesViewModelImplementation: VenuesViewModel {

    weak var viewDelegate: VenuesViewModelViewDelegate?
    var venues = [VenueCellViewModel]()

    private var dependencies: Dependencies
    private var cancellable: AnyCancellable?

    private var isFavorites: Bool = false {
        didSet {
            if isFavorites == true {
                venues = venues.filter { $0.isFavorite }
            } else {
                dependencies.locationService.getCurrentLocation()
            }
        }
    }
    private var isLoading: Bool = false {
        didSet {
            if isLoading == true {
                viewDelegate?.startLoading()
            } else {
                viewDelegate?.finishLoading()
            }
        }
    }
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        self.dependencies.locationService.delegate = self
    }
    
    func viewDidLoad() {
        dependencies.locationService.getCurrentLocation()
        dependencies.locationService.startGettingLocation()
    }

    var venuesCount: Int {
        return venues.count
    }

    func favoritesDidPress() {
        isFavorites.toggle()
    }

    var favoritesButtonImageName: BaseIcon {
        isFavorites ? .favoriteSelected : .favoriteNotSelected
    }

    func startRefreshing() {
        dependencies.locationService.getCurrentLocation()
    }
}

private extension VenuesViewModelImplementation {

    func fetchVenues(by coordinate: Coordinate) {
        isLoading = true
        
        let latitude = String(coordinate.latitude)
        let longitude = String(coordinate.longitude)

        cancellable = dependencies.venuesService
            .fetchVenues(by: [.latitude: latitude, .longitude: longitude])
            .map { values in
                values
                    .prefix(15)
                    .map { VenueCellViewModelImplementation(dependencies: self.dependencies, model: $0 ) }
            }
            .catch { error -> Just<[VenueCellViewModel]> in
                self.isLoading = false
                self.viewDelegate?.showCenteredMessage("Something went wrong.\nPlease try again later.")
                return Just([])
            }
            .sink(receiveCompletion: {_ in }, receiveValue: { [weak self] venues in
                if self?.isFavorites == true {
                    self?.venues = venues.filter { $0.isFavorite }
                } else {
                    self?.venues = venues
                }
                self?.isLoading = false
            })
    }
}

// MARK: - LocationServiceDelegate

extension VenuesViewModelImplementation: LocationServiceDelegate {
    func locationDidUpdateCurrentCoordinate(_ coordinate: Coordinate) {
        fetchVenues(by: coordinate)
    }
}
