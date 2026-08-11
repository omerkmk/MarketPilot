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
    private let favoriteStorage: FavoriteStorageProtocol
    private(set) var favoriteProducts: [Product] = []
    
    init(favoriteStorage: FavoriteStorageProtocol) {
        self.favoriteStorage = favoriteStorage
        do {
            favoriteProducts = try favoriteStorage.load()
        }
        
        catch {
            print("Favorite storage load failed:", error)
            
        }
    }
    
    private func saveFavorites() {
        do {
            try favoriteStorage.save(products: favoriteProducts)
        } catch {
            print("Favorite storage save failed:", error)
        }
    }
    
    
    func isFavorite(_ product: Product) -> Bool {
        return favoriteProducts.contains { favoriteProduct in
            favoriteProduct.id == product.id
        }
    }
    
    func add(product: Product) {
        if !isFavorite(product) {
            favoriteProducts.append(product)
            saveFavorites()
        }
       
    }
    
    func remove(product: Product) {
        guard isFavorite(product) else {
            return
        }

        favoriteProducts.removeAll { favoriteProduct in
            favoriteProduct.id == product.id
        }

        saveFavorites()
    }
    
    func toggle(product: Product) {
        if isFavorite(product) {
            remove(product: product)
        } else {
            add(product: product)
        }
    }
}
