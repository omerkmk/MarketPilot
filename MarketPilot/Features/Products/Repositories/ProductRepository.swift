//
//  ProductRepository.swift
//  MarketPilot
//
//  Created by ömer kumek on 18.09.2026.
//

import Foundation

final class ProductRepository : ProductRepositoryProtocol{
    private let productService: ProductServiceProtocol

    init(productService: ProductServiceProtocol) {
        self.productService = productService
    }



    func fetchProducts() async throws -> [Product] {
        try await productService.fetchProducts()
    }



}
