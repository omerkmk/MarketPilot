//
//  ProductDetailViewModelTests.swift
//  MarketPilotTests
//

import Testing
@testable import MarketPilot

@MainActor
struct ProductDetailViewModelTests {

    private func makeViewModel(
        product: Product,
        cartManager: CartManager = CartManager(),
        favoriteManager: FavoriteManager = FavoriteManager(favoriteStorage: InMemoryFavoriteStorage())
    ) -> ProductDetailViewModel {
        return ProductDetailViewModel(
            product: product,
            cartManager: cartManager,
            favoriteManager: favoriteManager
        )
    }

    @Test func addToCartSetsStateToInCartWithQuantityOneAndNotifies() {
        // Arrange
        let product = Product.stub()
        let viewModel = makeViewModel(product: product)
        var receivedStates: [ProductDetailCartState] = []
        viewModel.onCartStateChanged = { state in
            receivedStates.append(state)
        }

        // Act
        viewModel.addToCart()

        // Assert
        #expect(viewModel.cartState == .inCart(quantity: 1))
        #expect(receivedStates == [.inCart(quantity: 1)])
    }

    @Test func increaseQuantityMovesFromOneToTwoAndNotifies() {
        // Arrange
        let product = Product.stub()
        let cartManager = CartManager()
        cartManager.add(product: product)
        let viewModel = makeViewModel(product: product, cartManager: cartManager)
        var receivedStates: [ProductDetailCartState] = []
        viewModel.onCartStateChanged = { state in
            receivedStates.append(state)
        }

        // Act
        viewModel.increaseQuantity()

        // Assert
        #expect(viewModel.cartState == .inCart(quantity: 2))
        #expect(receivedStates == [.inCart(quantity: 2)])
    }

    @Test func decreaseQuantityMovesFromTwoToOneAndNotifies() {
        // Arrange
        let product = Product.stub()
        let cartManager = CartManager()
        cartManager.add(product: product)
        cartManager.add(product: product)
        let viewModel = makeViewModel(product: product, cartManager: cartManager)
        var receivedStates: [ProductDetailCartState] = []
        viewModel.onCartStateChanged = { state in
            receivedStates.append(state)
        }

        // Act
        viewModel.decreaseQuantity()

        // Assert
        #expect(viewModel.cartState == .inCart(quantity: 1))
        #expect(receivedStates == [.inCart(quantity: 1)])
    }

    @Test func decreaseQuantityAtOneBecomesNotInCartAndKeepsOtherProducts() {
        // Arrange
        let product = Product.stub(id: 1)
        let otherProduct = Product.stub(id: 2)
        let cartManager = CartManager()
        cartManager.add(product: product)
        cartManager.add(product: otherProduct)
        let viewModel = makeViewModel(product: product, cartManager: cartManager)

        // Act
        viewModel.decreaseQuantity()

        // Assert
        #expect(viewModel.cartState == .notInCart)
        #expect(cartManager.quantity(for: product) == 0)
        #expect(cartManager.quantity(for: otherProduct) == 1)
    }

    @Test func toggleFavoriteWhenNotFavoriteSetsTrueAndNotifies() {
        // Arrange
        let product = Product.stub()
        let viewModel = makeViewModel(product: product)
        var receivedValues: [Bool] = []
        viewModel.onFavoriteChanged = { value in
            receivedValues.append(value)
        }

        // Act
        viewModel.toggleFavorite()

        // Assert
        #expect(viewModel.isFavorite == true)
        #expect(receivedValues == [true])
    }

    @Test func togglingFavoriteTwiceReturnsToFalse() {
        // Arrange
        let product = Product.stub()
        let viewModel = makeViewModel(product: product)

        // Act
        viewModel.toggleFavorite()
        viewModel.toggleFavorite()

        // Assert
        #expect(viewModel.isFavorite == false)
    }

    @Test func initReflectsExistingCartQuantity() {
        // Arrange
        let product = Product.stub()
        let cartManager = CartManager()
        cartManager.add(product: product)
        cartManager.add(product: product)
        cartManager.add(product: product)

        // Act
        let viewModel = makeViewModel(product: product, cartManager: cartManager)

        // Assert
        #expect(viewModel.cartState == .inCart(quantity: 3))
    }

    @Test func refreshPicksUpCartChangesMadeElsewhere() {
        // Arrange
        let product = Product.stub()
        let cartManager = CartManager()
        let viewModel = makeViewModel(product: product, cartManager: cartManager)
        #expect(viewModel.cartState == .notInCart)
        var receivedStates: [ProductDetailCartState] = []
        viewModel.onCartStateChanged = { state in
            receivedStates.append(state)
        }

        // Act: başka bir ekran sepete doğrudan ekliyor
        cartManager.add(product: product)
        viewModel.refresh()

        // Assert
        #expect(viewModel.cartState == .inCart(quantity: 1))
        #expect(receivedStates == [.inCart(quantity: 1)])
    }
}
