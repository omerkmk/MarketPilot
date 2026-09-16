//
//  SortOption.swift
//  MarketPilot
//
//  Created by ömer kumek on 16.09.2026.
//

import Foundation

enum SortOption: CaseIterable {
    case priceAscending
    case priceDescending
    case titleAscending
    case titleDescending

    var displayTitle: String {
        switch self {
        case .priceAscending:
            return "Price: Low to High"
        case .priceDescending:
            return "Price: High to Low"
        case .titleAscending:
            return "Title: A–Z"
        case .titleDescending:
            return "Title: Z–A"
        }
    }
}
