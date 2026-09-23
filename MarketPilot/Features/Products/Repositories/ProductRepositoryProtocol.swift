//
//  ProductRepositoryProtocol.swift
//  MarketPilot
//
//  Created by ömer kumek on 18.09.2026.
//

import Foundation

protocol ProductRepositoryProtocol {

    func fetchProducts() async throws -> [Product]
}
