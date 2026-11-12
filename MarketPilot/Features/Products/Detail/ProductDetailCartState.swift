//
//  ProductDetailCartState.swift
//  MarketPilot
//
//  Created by ömer kumek on 30.09.2026.
//

import Foundation

enum ProductDetailCartState: Equatable {
    case notInCart
    case inCart(quantity: Int)
    
    var showsRemoveIcon: Bool {
        switch self {
        case .notInCart:
            return false
        case .inCart(let quantity):
            return quantity == 1
        }
    }
}
