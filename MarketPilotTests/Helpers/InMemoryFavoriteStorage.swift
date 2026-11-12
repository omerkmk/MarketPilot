//
//  InMemoryFavoriteStorage.swift
//  MarketPilotTests
//

import Foundation
@testable import MarketPilot

/// UserDefaults yerine bellekte çalışan sahte favori deposu.
final class InMemoryFavoriteStorage: FavoriteStorageProtocol {
    private(set) var savedProducts: [Product]

    init(initialProducts: [Product] = []) {
        self.savedProducts = initialProducts
    }

    func save(products: [Product]) throws {
        savedProducts = products
    }

    func load() throws -> [Product] {
        return savedProducts
    }
}
