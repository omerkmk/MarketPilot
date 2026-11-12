//
//  CartManagerTests.swift
//  MarketPilotTests
//
//  Created by ömer kumek on 29.09.2026.
//

import Testing
@testable import MarketPilot

struct CartManagerTests {

    @Test func quantityIsZeroForProductNotInCart() {
        // Arrange
        let cartManager = CartManager()
        let product = Product.stub()

        // Act: yok, ürünü bilerek eklemiyoruz

        // Assert
        #expect(cartManager.quantity(for: product) == 0)
    }

    @Test func addingNewProductSetsQuantityToOne() {
        // Arrange
        let cartManager = CartManager()
        let product = Product.stub()

        // Act
        cartManager.add(product: product)

        // Assert
        #expect(cartManager.quantity(for: product) == 1)
        #expect(cartManager.items.count == 1)
    }

    @Test func addingSameProductTwiceIncreasesQuantity() {
        // Arrange
        let cartManager = CartManager()
        let product = Product.stub()

        // Act: aynı ürünü iki kez ekle
        cartManager.add(product: product)
        cartManager.add(product: product)

        // Assert
        #expect(cartManager.quantity(for: product) == 2)
        #expect(cartManager.items.count == 1)
    }

    @Test func increaseQuantityAddsOne() {
        // Arrange
        let cartManager = CartManager()
        let product = Product.stub()
        cartManager.add(product: product)

        // Act
        cartManager.increaseQuantity(for: product)

        // Assert
        #expect(cartManager.quantity(for: product) == 2)
    }

    @Test func increaseQuantityDoesNothingForProductNotInCart() {
        // Arrange
        let cartManager = CartManager()
        let product = Product.stub()

        // Act
        cartManager.increaseQuantity(for: product)

        // Assert
        #expect(cartManager.quantity(for: product) == 0)
        #expect(cartManager.items.isEmpty)
    }

    @Test func decreaseQuantityRemovesOneWhenQuantityIsAboveOne() {
        // Arrange
        let cartManager = CartManager()
        let product = Product.stub()
        cartManager.add(product: product)
        cartManager.increaseQuantity(for: product)

        // Act
        cartManager.decreaseQuantity(for: product)

        // Assert
        #expect(cartManager.quantity(for: product) == 1)
    }

    @Test func decreaseQuantityRemovesProductWhenQuantityIsOne() {
        // Arrange
        let cartManager = CartManager()
        let product = Product.stub()
        cartManager.add(product: product)

        // Act
        cartManager.decreaseQuantity(for: product)

        // Assert
        #expect(cartManager.quantity(for: product) == 0)
        #expect(cartManager.items.isEmpty)
    }

    @Test func removeDeletesProductRegardlessOfQuantity() {
        // Arrange
        let cartManager = CartManager()
        let product = Product.stub()
        cartManager.add(product: product)
        cartManager.add(product: product)
        cartManager.add(product: product)

        // Act
        cartManager.remove(product: product)

        // Assert
        #expect(cartManager.items.isEmpty)
    }

    @Test func totalPriceAccountsForQuantities() {
        // Arrange
        let cartManager = CartManager()
        let product1 = Product.stub(id: 1, price: 10)
        let product2 = Product.stub(id: 2, price: 2.5)
        cartManager.add(product: product1)
        cartManager.add(product: product2)
        cartManager.add(product: product2)

        // Assert
        #expect(cartManager.totalPrice == 15.0)
    }

    @Test func totalPriceIsZeroForEmptyCart() {
        // Arrange
        let cartManager = CartManager()

        // Act: yok, sepet bilerek boş bırakılıyor

        // Assert
        #expect(cartManager.totalPrice == 0)
    }
}
