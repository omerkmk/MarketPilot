//
//  ProductDetailViewModel.swift
//  MarketPilot
//
//  Created by ömer kumek on 30.09.2026.
//

import Foundation

@MainActor
final class ProductDetailViewModel {

    let product: Product
    private let cartManager: CartManagerProtocol
    private let favoriteManager: FavoriteManagerProtocol

    private(set) var cartState: ProductDetailCartState
    private(set) var isFavorite: Bool
    var onCartStateChanged: ((ProductDetailCartState) -> Void)?
    var onFavoriteChanged: ((Bool) -> Void)?

    init(
        product: Product,
        cartManager: CartManagerProtocol,
        favoriteManager: FavoriteManagerProtocol
    ) {
        self.product = product
        self.cartManager = cartManager
        self.favoriteManager = favoriteManager
        self.cartState = Self.makeCartState(quantity: cartManager.quantity(for: product))
        self.isFavorite = favoriteManager.isFavorite(product)
    }

    func addToCart() {
        cartManager.add(product: product)
        reloadCartState()
    }

    func increaseQuantity() {
        cartManager.increaseQuantity(for: product)
        reloadCartState()
    }

    func decreaseQuantity() {
        cartManager.decreaseQuantity(for: product)
        reloadCartState()
    }

    func toggleFavorite() {
        favoriteManager.toggle(product: product)
        reloadFavorite()
    }

    func refresh() {
        reloadCartState()
        reloadFavorite()
    }

    private func reloadCartState() {
        let quantity = cartManager.quantity(for: product)
        updateCartState(Self.makeCartState(quantity: quantity))
    }

    private func reloadFavorite() {
        updateFavorite(favoriteManager.isFavorite(product))
    }

    private func updateCartState(_ newState: ProductDetailCartState) {
        cartState = newState
        onCartStateChanged?(newState)
    }

    private func updateFavorite(_ newValue: Bool) {
        isFavorite = newValue
        onFavoriteChanged?(newValue)
    }

    private static func makeCartState(quantity: Int) -> ProductDetailCartState {
        if quantity > 0 {
            return .inCart(quantity: quantity)
        } else {
            return .notInCart
        }
    }
}
