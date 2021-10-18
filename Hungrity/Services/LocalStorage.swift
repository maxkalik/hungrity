//
//  LocalStorage.swift
//  Hungrity
//
//  Created by Maksim Kalik on 10/18/21.
//

import Foundation

enum StorageKeys: String {
    case favorites
}

protocol LocalStorageProtocol {
    var favorites: Array<String> { get }
    
    func addFavorite(id: String)
    func removeFavorite(id: String)
}

final class LocalStorage: LocalStorageProtocol {
    
    private var storage: UserDefaults
    private(set) var favorites: Array<String>
    
    init() {
        storage = UserDefaults.standard
        favorites = storage.object(forKey: StorageKeys.favorites.rawValue) as? Array<String> ?? Array<String>()
    }
    
    func addFavorite(id: String) {
        favorites.append(id)
        updateStorage(forkey: .favorites)
    }
    
    func removeFavorite(id: String) {
        guard let index = favorites.firstIndex(of: id) else { return }
        favorites.remove(at: index)
        updateStorage(forkey: .favorites)
    }
    
    private func updateStorage(forkey: StorageKeys) {
        switch forkey {
        case .favorites:
            storage.set(favorites, forKey: forkey.rawValue)
        }
    }
}
