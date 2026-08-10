//
//  FavoritesViewController.swift
//  MarketPilot
//
//  Created by ömer kumek on 9.08.2026.
//

import UIKit

final class FavoritesViewController: UIViewController {

    private let favoriteManager: FavoriteManagerProtocol
    private let imageLoadingService: ImageLoadingServiceProtocol
    var onProductSelected: ((Product) -> Void)?

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No favorites yet."
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .preferredFont(forTextStyle: .body)
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()

        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground

        return collectionView
    }()

    init(
        favoriteManager: FavoriteManagerProtocol,
        imageLoadingService: ImageLoadingServiceProtocol
    ) {
        self.favoriteManager = favoriteManager
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
        refreshFavoritesUI()
    }

    private func setupHierarchy() {
        view.addSubview(collectionView)
        view.addSubview(emptyStateLabel)
    }

    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "Favorites"

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(
            ProductCollectionViewCell.self,
            forCellWithReuseIdentifier: ProductCollectionViewCell.reuseIdentifier
        )
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            emptyStateLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            emptyStateLabel.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),
            emptyStateLabel.leadingAnchor.constraint(
                greaterThanOrEqualTo: view.leadingAnchor,
                constant: 24
            ),
            emptyStateLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: view.trailingAnchor,
                constant: -24
            )
        ])
    }

    private func refreshFavoritesUI() {
        collectionView.reloadData()
        let isEmpty = favoriteManager.favoriteProducts.isEmpty

        collectionView.isHidden = isEmpty
        emptyStateLabel.isHidden = !isEmpty
    }
}

// MARK: - UICollectionViewDataSource

extension FavoritesViewController: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return favoriteManager.favoriteProducts.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let product = favoriteManager.favoriteProducts[indexPath.item]

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

extension FavoritesViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let selectedProduct = favoriteManager.favoriteProducts[indexPath.item]
        onProductSelected?(selectedProduct)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let horizontalPadding: CGFloat = 16
        let interItemSpacing: CGFloat = 12

        let availableWidth =
            collectionView.bounds.width
            - (horizontalPadding * 2)
            - interItemSpacing

        let itemWidth = availableWidth / 2

        return CGSize(
            width: itemWidth,
            height: 210
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: 16,
            left: 16,
            bottom: 16,
            right: 16
        )
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
}
