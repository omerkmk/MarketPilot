//
//  CartManager.swift
//  MarketPilot
//
//  Created by ömer kumek on 12.07.2026.
//
import Foundation

protocol CartManagerProtocol {
    var items: [CartItem] { get }
    var totalPrice: Double { get }

    func add(product: Product)
    func decreaseQuantity(for product: Product)
    func remove(product: Product)
    func increaseQuantity(for product: Product)
}

final class CartManager: CartManagerProtocol {
    private(set) var items: [CartItem] = []
    
    func add(product: Product) {
        let existingIndex = items.firstIndex { cartItem in
            cartItem.product.id == product.id
        }
        
        if let existingIndex = existingIndex {
            items[existingIndex].quantity += 1
        } else {
            let newItem = CartItem(
                product: product,
                quantity: 1
            )
            
            items.append(newItem)
        }
    }
    
    func remove(product: Product) {
        items.removeAll { cartItem in
            cartItem.product.id == product.id
        }
    }
    
    func decreaseQuantity(for product: Product) {
        guard let existingIndex = items.firstIndex(where: { cartItem in
            cartItem.product.id == product.id
        }) else {
            return
        }

        if items[existingIndex].quantity > 1 {
            items[existingIndex].quantity -= 1
        } else {
            items.remove(at: existingIndex)
        }
    }
    
    func increaseQuantity(for product: Product) {
        guard let existingIndex = items.firstIndex(where: { cartItem in
            cartItem.product.id == product.id
        }) else {
            return
        }

        items[existingIndex].quantity += 1
    }
    
    
    var totalPrice: Double {
        items.reduce(0) { result, item in
            result + item.product.price * Double(item.quantity)
        }
    }
    
}
