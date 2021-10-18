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
    @Published private(set) var venues = [Venue]()
    @Published private(set) var state: ListViewModelState = .loading

    private var dependencies: Dependencies
    private var cancellable: AnyCancellable?
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func viewDidLoad() {
        fetchVenues()
        dependencies.locationService.start()
    }
    
    func fetchVenues() {

        cancellable = dependencies.venuesService
            .fetchVenues(by: [.latitude: "60.170187", .longitude: "24.930599"])
            .catch { [self] error -> Just<[Venue]> in
                return Just([])
            }
            .sink(receiveCompletion: {_ in }, receiveValue: { [self] venues in
                self.venues = venues
                print(venues.first)
            })
    }
}
