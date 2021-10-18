//
//  VenuesViewModel.swift
//  Hungrity
//
//  Created by Maksim Kalik on 10/16/21.
//

import Foundation
import Combine
import CoreLocation

enum ListViewModelState {
    case loading
    case finishedLoading
    case error(Error)
}

final class VenuesViewModel {
    private var allVenues = [Venue]() {
        didSet {
            self.getVenues()
            guard timer == nil else { return }
            self.timer = Timer.scheduledTimer(
                timeInterval: 10,
                target: self,
                selector: #selector(self.getVenues),
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
    
    private var venuesCount: Int = 0
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        dependencies.locationService.delegate = self
        dependencies.locationService.start()
    }

    func viewDidLoad() {
        
    }
    
    @objc func getVenues() {
        print("--->", 15 + venuesCount)
        let venueElements: [Venue]
        if allVenues.count >= 15 + venuesCount {
            let indexFrom = 0 + venuesCount
            let indexTill = 15 + venuesCount
            venueElements = Array(allVenues[indexFrom ..< indexTill])
            venuesCount += 15
        } else {
            venueElements = allVenues
            timer?.invalidate()
            timer = nil
        }
        print("**** \(venueElements)")
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
