//
//  AppCoordinator.swift
//  MarketPilot
//
//  Created by ömer kumek on 22.05.2026.
//


import UIKit

final class AppCoordinator {
    
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let productListViewController = ProductListViewController()
        navigationController.setViewControllers([productListViewController], animated: false)
    }
}
