//
//  AppCoordinator.swift
//  MarketPilot
//
//  Created by ömer kumek on 22.05.2026.
//

import UIKit

final class AppCoordinator {

    private let navigationController: UINavigationController
    private let productService: ProductServiceProtocol
    private let imageLoadingService: ImageLoadingServiceProtocol
    private let cartManager: CartManagerProtocol
    private let favoriteManager: FavoriteManagerProtocol

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.productService = ProductService()
        self.imageLoadingService = ImageLoadingService()
        self.cartManager = CartManager()
        self.favoriteManager = FavoriteManager()
    }

    func start() {
        let productListViewController = ProductListViewController(
            productService: productService,
            imageLoadingService: imageLoadingService,
            favoriteManager: favoriteManager
        )

        productListViewController.onProductSelected = { [weak self] product in
            self?.showProductDetail(product)
        }

        productListViewController.onCartTapped = { [weak self] in
            self?.showCart()
        }

        productListViewController.onFavoritesTapped = { [weak self] in
            self?.showFavorites()
        }

        navigationController.setViewControllers(
            [productListViewController],
            animated: false
        )
    }

    private func showProductDetail(_ product: Product) {
        let productDetailViewController = ProductDetailViewController(
            product: product,
            imageLoadingService: imageLoadingService,
            cartManager: cartManager,
            favoriteManager: favoriteManager
        )

        navigationController.pushViewController(
            productDetailViewController,
            animated: true
        )
    }

    private func showCart() {
        let cartViewController = CartViewController(
            cartManager: cartManager,
            imageLoadingService: imageLoadingService
        )

        navigationController.pushViewController(
            cartViewController,
            animated: true
        )
    }

    private func showFavorites() {
        let favoritesViewController = FavoritesViewController(
            favoriteManager: favoriteManager,
            imageLoadingService: imageLoadingService
        )

        favoritesViewController.onProductSelected = { [weak self] product in
            self?.showProductDetail(product)
        }

        navigationController.pushViewController(
            favoritesViewController,
            animated: true
        )
    }
}
