//
//  FavoriteManager.swift
//  MarketPilot
//
//  Created by ömer kumek on 8.08.2026.
//

protocol FavoriteManagerProtocol {
    var favoriteProducts: [Product] { get }
    func isFavorite(_ product: Product) -> Bool
    func add(product: Product)
    func remove(product: Product)
    func toggle(product: Product)
}

final class FavoriteManager: FavoriteManagerProtocol {
    private(set) var favoriteProducts: [Product] = []
    
    func isFavorite(_ product: Product) -> Bool {
        return favoriteProducts.contains { favoriteProduct in
            favoriteProduct.id == product.id
        }
    }
    
    func add(product: Product) {
        if !isFavorite(product) {
            favoriteProducts.append(product)
        }
    }
    
    func remove(product: Product) {
        favoriteProducts.removeAll { favoriteProduct in
            favoriteProduct.id == product.id
        }
    }
    
    func toggle(product: Product) {
        if isFavorite(product) {
            remove(product: product)
        } else {
            add(product: product)
        }
    }
}
