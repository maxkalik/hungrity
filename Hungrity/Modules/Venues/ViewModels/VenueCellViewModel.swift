//
//  VenueViewModel.swift
//  Hungrity
//
//  Created by Maksim Kalik on 10/19/21.
//

import Foundation

protocol VenueCellViewModel {
    var isFavorite: Bool { get }
    var title: String { get }
    var subTitle: String? { get }
    var imageUrl: URL? { get }
    var favoriteButtonImage: String { get }
    
    func favoriteDidPress()
}

final class VenueCellViewModelImplementation: VenueCellViewModel {

    private var venue: Venue
    private var dependencies: HasLocalStorage
    
    var isFavorite: Bool = false
    
    init(dependencies: HasLocalStorage, model: Venue) {
        self.dependencies = dependencies
        self.venue = model
    }
    
    var title: String {
        venue.name ?? "Unknown"
    }
    
    var subTitle: String? {
        venue.shortDescription
    }
    
    var imageUrl: URL? {
        guard let urlString = venue.listimage else { return nil }
        return URL(string: urlString)
    }
    
    var favoriteButtonImage: String {
        isFavorite ? "" : ""
    }

    func favoriteDidPress() {
        print(#function)
    }
}
