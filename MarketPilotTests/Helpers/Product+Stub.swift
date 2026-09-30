//
//  Product+Stub.swift
//  MarketPilotTests
//
//  Created by ömer kumek on 29.09.2026.
//

import Foundation
@testable import MarketPilot

extension Product {
    static func stub(id: Int = 1, price: Double = 10) -> Product {
        let testProduct = Product(
            id: id,
            title: "Test Product",
            price: price,
            category: "Test category",
            description: "Test product",
            image: nil
        )

        return testProduct
    }
}
