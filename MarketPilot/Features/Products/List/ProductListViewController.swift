//
//  ProductListViewController.swift
//  MarketPilot
//
//  Created by ömer kumek on 22.05.2026.
//

import UIKit

final class ProductListViewController: UIViewController {

    private let productService: ProductServiceProtocol
    private let imageLoadingService: ImageLoadingServiceProtocol
    private var products: [Product] = []
    private let favoriteManager: FavoriteManagerProtocol

    var onProductSelected: ((Product) -> Void)?
    var onCartTapped: (() -> Void)?
    var onFavoritesTapped: (() -> Void)?

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.isHidden = true
        return collectionView
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No products found."
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .preferredFont(forTextStyle: .body)
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Something went wrong. Please try again."
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .preferredFont(forTextStyle: .body)
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    init(
        productService: ProductServiceProtocol,
        imageLoadingService: ImageLoadingServiceProtocol,
        favoriteManager: FavoriteManagerProtocol
    ) {
        self.productService = productService
        self.imageLoadingService = imageLoadingService
        self.favoriteManager = favoriteManager
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
        setupHierarchy()
        setupLayout()
        loadProducts()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }

    private func setupNavigationBar() {
        let cartButton = UIBarButtonItem(
            image: UIImage(systemName: "cart"),
            style: .plain,
            target: self,
            action: #selector(cartButtonTapped)
        )

        let favoritesButton = UIBarButtonItem(
            image: UIImage(systemName: "heart"),
            style: .plain,
            target: self,
            action: #selector(favoritesButtonTapped)
        )

        navigationItem.rightBarButtonItems = [
            cartButton,
            favoritesButton
        ]
    }

    @objc private func favoritesButtonTapped() {
        onFavoritesTapped?()
    }

    @objc private func cartButtonTapped() {
        onCartTapped?()
    }

    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "Products"

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            ProductCollectionViewCell.self,
            forCellWithReuseIdentifier: ProductCollectionViewCell.reuseIdentifier
        )
    }

    private func setupHierarchy() {
        view.addSubview(collectionView)
        view.addSubview(loadingIndicator)
        view.addSubview(emptyStateLabel)
        view.addSubview(errorLabel)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),

            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            errorLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])
    }

    private func loadProducts() {
        showLoading()

        Task {
            do {
                let fetchedProducts = try await productService.fetchProducts()
                self.products = fetchedProducts
                self.collectionView.reloadData()

                if fetchedProducts.isEmpty {
                    self.showEmpty()
                } else {
                    self.showProducts()
                }
            } catch {
                self.showError()
                print(error)
            }
        }
    }

    @MainActor
    private func showLoading() {
        collectionView.isHidden = true
        emptyStateLabel.isHidden = true
        errorLabel.isHidden = true
        loadingIndicator.startAnimating()
    }

    @MainActor
    private func showProducts() {
        loadingIndicator.stopAnimating()
        emptyStateLabel.isHidden = true
        errorLabel.isHidden = true
        collectionView.isHidden = false
    }

    @MainActor
    private func showEmpty() {
        loadingIndicator.stopAnimating()
        collectionView.isHidden = true
        errorLabel.isHidden = true
        emptyStateLabel.isHidden = false
    }

    @MainActor
    private func showError() {
        loadingIndicator.stopAnimating()
        collectionView.isHidden = true
        emptyStateLabel.isHidden = true
        errorLabel.isHidden = false
    }
}

// MARK: - UICollectionViewDataSource

extension ProductListViewController: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return products.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let product = products[indexPath.item]

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ProductCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? ProductCollectionViewCell else {
            return UICollectionViewCell()
        }

        let isFavorite = favoriteManager.isFavorite(product)

        cell.configure(
            with: product,
            imageLoadingService: imageLoadingService,
            isFavorite: isFavorite
        )
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ProductListViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let horizontalPadding: CGFloat = 16
        let interItemSpacing: CGFloat = 12
        let availableWidth = collectionView.bounds.width - (horizontalPadding * 2) - interItemSpacing
        let itemWidth = availableWidth / 2

        return CGSize(width: itemWidth, height: 210)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 16
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 12
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let selectedProduct = products[indexPath.item]
        onProductSelected?(selectedProduct)
    }
}
