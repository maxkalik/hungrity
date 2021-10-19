//
//  VenueViewModel.swift
//  Hungrity
//
//  Created by Maksim Kalik on 10/19/21.
//

import Foundation

protocol VenueCellViewModel {
    var title: String { get }
    var subTitle: String? { get }
    var imageUrl: URL? { get }
    var favoriteButtonImageName: String { get }
    
    func favoriteDidPress()
}

final class VenueCellViewModelImplementation: VenueCellViewModel {

    private var venue: Venue
    private var dependencies: HasLocalStorage
    private var isFavorite: Bool
    
    init(dependencies: HasLocalStorage, model: Venue) {
        self.dependencies = dependencies
        self.venue = model
        self.isFavorite = dependencies.localStorage.favorites.contains(venue.id)
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
    
    var favoriteButtonImageName: String {
        isFavorite ? "favorite_filled" : "favorite_border"
    }

    func favoriteDidPress() {
        dependencies.localStorage.addFavorite(id: venue.id)
        isFavorite = true
    }
}
