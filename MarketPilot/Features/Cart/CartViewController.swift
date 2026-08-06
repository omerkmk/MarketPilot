//
//  CartViewController.swift
//  MarketPilot
//
//  Created by ömer kumek on 4.08.2026.
//

import UIKit

final class CartViewController: UIViewController {
    
    private let cartManager: CartManagerProtocol
    private let imageLoadingService: ImageLoadingServiceProtocol
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let totalPriceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .title2)
        label.textColor = .label
        label.textAlignment = .right
        label.text = "Total: $0.00"
        return label
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Your cart is empty."
        label.font = .preferredFont(forTextStyle: .title3)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    
    init(
        cartManager: CartManagerProtocol,
        imageLoadingService: ImageLoadingServiceProtocol
    ) {
        self.cartManager = cartManager
        self.imageLoadingService = imageLoadingService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupHierarchy()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshCartUI()
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "Cart"
        
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 112
        
        tableView.register(
            CartItemCell.self,
            forCellReuseIdentifier: CartItemCell.reuseIdentifier
        )
    }
    
    private func setupHierarchy() {
        view.addSubview(tableView)
        view.addSubview(totalPriceLabel)
        view.addSubview(emptyStateLabel)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            tableView.bottomAnchor.constraint(
                equalTo: totalPriceLabel.topAnchor,
                constant: -12
            ),
            totalPriceLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            totalPriceLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
            totalPriceLabel.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -12
            ),
            emptyStateLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 24
            ),
            emptyStateLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -24
            ),
            emptyStateLabel.centerYAnchor.constraint(
                equalTo: tableView.centerYAnchor
            )
        ])
    }
    
    private func updateTotalPrice() {
        totalPriceLabel.text = String(
            format: "Total: $%.2f",
            cartManager.totalPrice
        )
    }
    
    private func updateEmptyState() {
        let isCartEmpty = cartManager.items.isEmpty
        emptyStateLabel.isHidden = !isCartEmpty
    }
    
    private func refreshCartUI() {
        tableView.reloadData()
        updateTotalPrice()
        updateEmptyState()
        
        
    }
    
}

extension CartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartManager.items.count
    }
    

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cartItem = cartManager.items[indexPath.row]

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CartItemCell.reuseIdentifier,
            for: indexPath
        ) as? CartItemCell else {
            return UITableViewCell()
        }

        cell.configure(
            with: cartItem,
            imageLoadingService: imageLoadingService
        )

        cell.onDecreaseTapped = { [weak self] in
            self?.cartManager.decreaseQuantity(for: cartItem.product)
            self?.refreshCartUI()
            
        }
        
        cell.onIncreaseTapped = { [weak self] in
            self?.cartManager.increaseQuantity(for: cartItem.product)
            self?.refreshCartUI()
        }
        
        cell.onRemoveTapped = {[weak self] in
            self?.cartManager.remove(product: cartItem.product)
            self?.refreshCartUI()
            
            
        }
        
        return cell
    }
    
    
}
