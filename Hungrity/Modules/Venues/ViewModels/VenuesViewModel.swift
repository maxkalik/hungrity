//
//  VenuesViewModel.swift
//  Hungrity
//
//  Created by Maksim Kalik on 10/16/21.
//

import Foundation
import Combine

enum ListViewModelState {
    case loading
    case finishedLoading
    case error(Error)
}

final class VenuesViewModel {
    @Published private(set) var venues = [Venue]()
    @Published private(set) var state: ListViewModelState = .loading
    
    private var cancellable: AnyCancellable?
    
//    private let venuesService: VenuesService = VenuesServiceImplementation()

    func viewDidLoad() {
        print("view did load")
        fetchVenues()
    }
    
    func fetchVenues() {
        
//        let receiveCompletionHandler: (Subscribers.Completion<Error>) -> Void = { [weak self] completion in
//            switch completion {
//            case .failure(let error):
//                print(error.localizedDescription)
//                self?.state = .error(error)
//            case .finished: self?.state = .finishedLoading
//            }
//        }
//
//        let receiveValueHandler: ([Venue]) -> Void = { [weak self] venues in
//            print(venues)
//            self?.venues = venues
//        }
//
//        cancellable = venuesService
//            .getVenues(by: [.latitude: "60.170187", .longitude: "24.930599"])
//            .sink(receiveCompletion: receiveCompletionHandler, receiveValue: receiveValueHandler)
        
        cancellable = NetworkService
            .fetchVenues(with: [.latitude: "60.170187", .longitude: "24.930599"])
            .catch { [self] failureReason -> Just<Venues> in
                return Just(Venues(results: [], status: .failed))
            }
            .sink(receiveCompletion: {_ in }, receiveValue: { [self] venues in
                self.venues = venues.results ?? []
                print(venues)
            })
    }
}
