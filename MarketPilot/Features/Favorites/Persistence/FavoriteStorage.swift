//
//  FavoriteStorage.swift
//  MarketPilot
//
//  Created by ömer kumek on 10.08.2026.
//

import Foundation

protocol FavoriteStorageProtocol {
    func save(products: [Product]) throws
    func load() throws -> [Product]
}

struct UserDefaultsFavoriteStorage: FavoriteStorageProtocol {

    private let userDefaults: UserDefaults
    private let favoriteProductsKey = "favoriteProducts"

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    func save(products: [Product]) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(products)

        userDefaults.set(data, forKey: favoriteProductsKey)
    }

    func load() throws -> [Product] {
        guard let data = userDefaults.data(forKey: favoriteProductsKey) else {
            return []
        }

        let decoder = JSONDecoder()
        let favoriteProducts = try decoder.decode([Product].self, from: data)
        return favoriteProducts
    }
}
