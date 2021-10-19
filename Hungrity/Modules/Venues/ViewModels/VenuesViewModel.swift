//
//  VenuesViewModel.swift
//  Hungrity
//
//  Created by Maksim Kalik on 10/16/21.
//

import Foundation
import Combine
import CoreLocation
import UIKit

protocol VenuesViewModelViewDelegate: AnyObject {
    func startLoading()
    func finishLoading()
}

protocol VenuesViewModel {
    var viewDelegate: VenuesViewModelViewDelegate? { get set }
    var venuesCount: Int { get }
    var venues: [VenueCellViewModel] { get }
    
    func viewDidLoad()
    func startRefreshing()
}

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
                selector: #selector(self.prepareVenues),
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
    
    @objc func appMovedToBackground() {
        resetVenues()
    }
    
    @objc func appWillEnterForeground() {
        dependencies.locationService.getLocation()
    }
    
    @objc func prepareVenues() {
        // print("--->", Configuration.maxVenuesItems + venuesCounter)
        self.viewDelegate?.startLoading()
        
        let venueElements: [Venue]
        let indexFrom = venuesCounter
        let indexTill = Configuration.maxVenuesItems + venuesCounter

        let filteredVenues = isFavorites ? allVenues.filter { self.dependencies.localStorage.favorites.contains($0.id) } : allVenues
        
        if filteredVenues.count >= indexTill {
            venueElements = Array(filteredVenues[indexFrom ..< indexTill])
            venuesCounter += Configuration.maxVenuesItems
        } else {
            venueElements = Array(filteredVenues[indexFrom ..< filteredVenues.count])
            resetVenues()
            DispatchQueue.main.asyncAfter(deadline: .now() + Configuration.refreshDeadlineSeconds) {
                self.dependencies.locationService.getLocation()
            }
        }

        print("**** \(venueElements)")
        self.venues = venueElements.map { VenueCellViewModelImplementation(dependencies: dependencies, model: $0 )}
        self.viewDelegate?.finishLoading()
    }
    
//    private func addFavorite(id: String) {
//        dependencies.localStorage.addFavorite(id: id)
//    }
    
    func resetVenues() {
        timer?.invalidate()
        timer = nil
        venues.removeAll()
        venuesCounter = 0
    }
    
    func fetchVenues(by coordinate: Coordinate) {
        
        viewDelegate?.startLoading()
        
        let latitude = String(coordinate.latitude)
        let longitude = String(coordinate.longitude)

        cancellable = dependencies.venuesService
            .fetchVenues(by: [.latitude: latitude, .longitude: longitude])
            .catch { error -> Just<[Venue]> in
                self.viewDelegate?.finishLoading()
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
    
    func startRefreshing() {
        timer?.invalidate()
        timer = nil
        venuesCounter = 0
        dependencies.locationService.getLocation()
    }
}

// MARK: - LocationServiceDelegate

extension VenuesViewModelImplementation: LocationServiceDelegate {
    func locationDidUpdateCurrentCoordinate(_ coordinate: Coordinate) {
        print("=== did update current coordinate: \(coordinate.latitude), \(coordinate.longitude)")
        fetchVenues(by: coordinate)
    }
    
    func locationDidFailWithError(_ error: Error) {
        print("=== location did failed")
    }
}
