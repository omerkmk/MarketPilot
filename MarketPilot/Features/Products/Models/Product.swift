//
//  Product.swift
//  MarketPilot
//
//  Created by ömer kumek on 25.06.2026.
//


struct Product: Codable {
    let id: Int
    let title: String
    let price: Double
    let category: String
    let description: String
    let image: String?
}
