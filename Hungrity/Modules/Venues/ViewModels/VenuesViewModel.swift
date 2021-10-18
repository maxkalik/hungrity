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

enum ListViewModelState {
    case loading
    case finishedLoading
    case error(Error)
}

final class VenuesViewModel {
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
    
    @Published private(set) var state: ListViewModelState = .loading
    
    private var venues = [Venue]()
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
        print("--->", Configuration.maxVenuesItems + venuesCounter)
        let venueElements: [Venue]
        let indexFrom = venuesCounter
        let indexTill = Configuration.maxVenuesItems + venuesCounter

        if allVenues.count >= indexTill {
            venueElements = Array(allVenues[indexFrom ..< indexTill])
            venuesCounter += Configuration.maxVenuesItems
        } else {
            venueElements = Array(allVenues[indexFrom ..< allVenues.count])            
            resetVenues()
            DispatchQueue.main.asyncAfter(deadline: .now() + Configuration.refreshDeadlineSeconds) {
                self.dependencies.locationService.getLocation()
            }
        }
        print("**** \(venueElements)")
    }
    
    private func addFavorite(id: String) {
        dependencies.localStorage.addFavorite(id: id)
    }
    
    func resetVenues() {
        timer?.invalidate()
        timer = nil
        venues.removeAll()
        venuesCounter = 0
    }
    
    func fetchVenues(by coordinate: Coordinate) {
        
        let latitude = String(coordinate.latitude)
        let longitude = String(coordinate.longitude)

        cancellable = dependencies.venuesService
            .fetchVenues(by: [.latitude: latitude, .longitude: longitude])
            .catch { error -> Just<[Venue]> in
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

extension VenuesViewModel: LocationServiceDelegate {
    func didUpdateCurrentCoordinate(_ coordinate: Coordinate) {
        print("=== did update current coordinate: \(coordinate.latitude), \(coordinate.longitude)")
        fetchVenues(by: coordinate)
    }
    
    func didFailWithError(_ error: Error) {
        print("location did failed")
    }
}
