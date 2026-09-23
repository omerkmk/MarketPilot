//
//  ProductListViewModel.swift
//  MarketPilot
//
//  Created by ömer kumek on 17.09.2026.
//

import Foundation
@MainActor
final class ProductListViewModel {


    private(set) var originalProducts: [Product] = []
    private(set) var displayedProducts: [Product] = []

    private(set) var selectedCategory: String?
    private(set) var availableCategories: [String] = []
    private(set) var selectedSort: SortOption?
    private(set) var searchText: String = ""
    private let productRepository: ProductRepositoryProtocol
    private(set) var state: ProductListViewState = .idle
    var onStateChanged: ((ProductListViewState) -> Void)?

    private func updateState(_ newState: ProductListViewState){
        state = newState
        onStateChanged?(newState)

    }

    func loadProducts() async {
        updateState(.loading)
        do{
            let products = try await productRepository.fetchProducts()
            setProducts(products)


            if displayedProducts .isEmpty {
                updateState(.empty)
            }
            else{
                updateState(.loaded)
            }

        }

        catch{
            print("Product loading failed:", error)
            updateState(.error)

        }
    }


    init(productRepository: ProductRepositoryProtocol){
        self.productRepository = productRepository
    }

    private func setProducts(_ fetchedProducts: [Product]){
        originalProducts = fetchedProducts
        let categories = fetchedProducts.map{
            product in product.category
        }

        availableCategories = Set(categories).sorted()
        displayedProducts = fetchedProducts

    }

    func updateSearchText(_ text: String) {
        searchText = text
        applyFilters()
    }

    private func applyFilters() {
        var filteredProducts = originalProducts

        let normalizedSearchText = searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        if !normalizedSearchText.isEmpty {
            filteredProducts = filteredProducts.filter { product in
                product.title
                    .lowercased()
                    .contains(normalizedSearchText)
            }
        }

        if let selectedCategory {
            filteredProducts = filteredProducts.filter { product in
                product.category == selectedCategory
            }
        }

        if let selectedSort {
            switch selectedSort {
            case .priceAscending:
                filteredProducts.sort { $0.price < $1.price }

            case .priceDescending:
                filteredProducts.sort { $0.price > $1.price }

            case .titleAscending:
                filteredProducts.sort {
                    $0.title.lowercased() < $1.title.lowercased()
                }

            case .titleDescending:
                filteredProducts.sort {
                    $0.title.lowercased() > $1.title.lowercased()
                }
            }
        }

        displayedProducts = filteredProducts

        if displayedProducts.isEmpty {
            updateState(.empty)
        } else {
            updateState(.loaded)
        }
    }

    func selectCategory(_ category: String?) {
        selectedCategory = category
        applyFilters()
    }

    func selectSort(_ sort: SortOption?) {
        selectedSort = sort
        applyFilters()
    }

}
