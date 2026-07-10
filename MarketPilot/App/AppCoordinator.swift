//
//  AppCoordinator.swift
//  MarketPilot
//
//  Created by ömer kumek on 22.05.2026.
//


import UIKit

import UIKit

final class AppCoordinator {
    
    private let navigationController: UINavigationController
    
    private let productService: ProductServiceProtocol
    private let imageLoadingService: ImageLoadingServiceProtocol
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.productService = ProductService()
        self.imageLoadingService = ImageLoadingService()
    }
    
    func start() {
        let productListViewController = ProductListViewController(
            productService: productService,
            imageLoadingService: imageLoadingService
        )
        
        productListViewController.onProductSelected = { [weak self] product in
            self?.showProductDetail(product)
        }
        
        navigationController.setViewControllers([productListViewController], animated: false)
    }
    
    private func showProductDetail(_ product: Product) {
        let productDetailViewController = ProductDetailViewController(
            product: product,
            imageLoadingService: imageLoadingService
        )
        
        navigationController.pushViewController(productDetailViewController, animated: true)
    }
}
