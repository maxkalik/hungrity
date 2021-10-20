//  Created by Maksim Kalik

import Foundation

protocol VenueCellViewModel {
    var title: String { get }
    var subTitle: String? { get }
    var imageUrl: URL? { get }
    var isFavorite: Bool { get }
    var favoriteButtonImageName: BaseIcon { get }
    
    func favoriteDidPress()
}

final class VenueCellViewModelImplementation: VenueCellViewModel {

    private var venue: Venue
    private var dependencies: HasLocalStorage
    var isFavorite: Bool
    
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
    
    var favoriteButtonImageName: BaseIcon {
        isFavorite ? .favoriteSelected : .favoriteNotSelected
    }

    func favoriteDidPress() {
        isFavorite.toggle()
        if isFavorite == true {
            dependencies.localStorage.addFavorite(id: venue.id)
        } else {
            dependencies.localStorage.removeFavorite(id: venue.id)
        }
    }
}
