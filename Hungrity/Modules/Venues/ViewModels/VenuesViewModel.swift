//  Created by Maksim Kalik

import Foundation
import Combine
import CoreLocation
import UIKit

protocol VenuesViewModelViewDelegate: AnyObject {
    func startLoading()
    func finishLoading()
    func showErrorMessage(_ msg: String)
}

protocol VenuesViewModel {
    var viewDelegate: VenuesViewModelViewDelegate? { get set }
    var venuesCount: Int { get }
    var venues: [VenueCellViewModel] { get }
    var favoritesButtonImageName: String { get }
    
    func viewDidLoad()
    func viewWillAppear()
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
    
    private var allVenues = [Venue]() {
        didSet {
            guard allVenues.isEmpty == false else { return }
            self.prepareVenues()
            guard timer == nil else { return }
            self.timer = Timer.scheduledTimer(
                timeInterval: Configuration.refreshDeadlineSeconds,
                target: self,
                selector: #selector(prepareVenues),
                userInfo: nil,
                repeats: true
            )
        }
    }

    var venues = [VenueCellViewModel]()

    private var timer: Timer?
    private var dependencies: Dependencies
    private var cancellable: AnyCancellable?
    private var venuesCounter: Int = 0
    private var isFavorites: Bool = false
    private var isLoading: Bool = false {
        didSet {
            if isLoading {
                viewDelegate?.startLoading()
            } else {
                viewDelegate?.finishLoading()
            }
        }
    }
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        dependencies.locationService.delegate = self
        dependencies.locationService.getLocation()
        
        print(dependencies.localStorage.favorites)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var venuesCount: Int {
        return venues.count
    }

    func viewDidLoad() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self, selector: #selector(appMovedToBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        notificationCenter.addObserver(
            self, selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    func viewWillAppear() {
        isLoading = true
    }

    func favoritesDidPress() {
        isFavorites.toggle()
        if isFavorites == true {
            showOnlyFavorites()
        } else {
            dependencies.locationService.getLocation()
        }
    }

    var favoritesButtonImageName: String {
        isFavorites ? "favorite_filled" : "favorite_border"
    }

    func startRefreshing() {
        stopTimer()
        dependencies.locationService.getLocation()
    }
}

private extension VenuesViewModelImplementation {
    @objc func appMovedToBackground() {
        resetVenues()
    }
    
    @objc func appWillEnterForeground() {
        dependencies.locationService.getLocation()
    }
    
    @objc func prepareVenues() {
        let indexTill = Configuration.maxVenuesItems + venuesCounter

        venues = prepareVenuesFrom(venuesCounter, till: indexTill)
            .map { VenueCellViewModelImplementation(dependencies: dependencies, model: $0 )}
        isLoading = false
    }
    
    private func prepareVenuesFrom(_ from: Int, till: Int) -> [Venue] {
        let venueElements: [Venue]
        if allVenues.count >= till {
            venueElements = Array(allVenues[from ..< till])
            venuesCounter += Configuration.maxVenuesItems
        } else {
            venueElements = Array(allVenues[from ..< allVenues.count])
            resetVenues()
            DispatchQueue.main.asyncAfter(deadline: .now() + Configuration.refreshDeadlineSeconds) { [weak self] in
                self?.dependencies.locationService.getLocation()
            }
        }
        return venueElements
    }

    func showOnlyFavorites() {
        resetVenues()
        self.venues = allVenues
            .filter { self.dependencies.localStorage.favorites.contains($0.id) }
            .map { VenueCellViewModelImplementation(dependencies: dependencies, model: $0 )}
    }

    func resetVenues() {
        stopTimer()
        venues.removeAll()
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        venuesCounter = 0
    }
    
    func fetchVenues(by coordinate: Coordinate) {

        let latitude = String(coordinate.latitude)
        let longitude = String(coordinate.longitude)

        cancellable = dependencies.venuesService
            .fetchVenues(by: [.latitude: latitude, .longitude: longitude])
            .catch { error -> Just<[Venue]> in
                self.isLoading = false
                self.viewDelegate?.showErrorMessage("Something went wrong.\nPlease try again later.")
                return Just([])
            }
            .sink(receiveCompletion: {_ in }, receiveValue: { [weak self] venues in
                guard let self = self else { return }
                if self.allVenues.isEmpty == false {
                    self.allVenues.removeAll()
                }
                self.allVenues = venues
            })
    }
}

// MARK: - LocationServiceDelegate

extension VenuesViewModelImplementation: LocationServiceDelegate {
    func locationDidUpdateCurrentCoordinate(_ coordinate: Coordinate) {
        isLoading = true
        fetchVenues(by: coordinate)
    }
    
    func locationDidFailWithError(_ error: Error) {
        isLoading = false
        self.viewDelegate?.showErrorMessage("Something wrong with defining your location.\nPlease try again later.")
    }
}
