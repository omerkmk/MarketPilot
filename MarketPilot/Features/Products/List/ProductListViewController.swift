import UIKit

final class ProductListViewController: UIViewController {

    private let productService: ProductServiceProtocol
    private let imageLoadingService: ImageLoadingServiceProtocol
    private let favoriteManager: FavoriteManagerProtocol

    private var originalProducts: [Product] = []
    private var displayedProducts: [Product] = []
    private var selectedCategory: String?
    private var availableCategories: [String] = []
    private var selectedSort: SortOption?

    var onProductSelected: ((Product) -> Void)?
    var onCartTapped: (() -> Void)?
    var onFavoritesTapped: (() -> Void)?

    private let searchController = UISearchController(
        searchResultsController: nil
    )

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()

        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )

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

    private let categoryButton: UIButton = {
        let button = UIButton(type: .system)

        button.translatesAutoresizingMaskIntoConstraints = false

        var configuration = UIButton.Configuration.tinted()
        configuration.title = "Category"
        configuration.image = UIImage(
            systemName: "line.3.horizontal.decrease.circle"
        )
        configuration.imagePlacement = .leading
        configuration.imagePadding = 6
        configuration.cornerStyle = .capsule
        configuration.baseForegroundColor = .label
        configuration.baseBackgroundColor = .secondarySystemBackground

        button.configuration = configuration

        return button
    }()

    private let sortButton: UIButton = {
        let button = UIButton(type: .system)

        button.translatesAutoresizingMaskIntoConstraints = false

        var configuration = UIButton.Configuration.tinted()
        configuration.title = "Sort"
        configuration.image = UIImage(
            systemName: "arrow.triangle.2.circlepath"
        )
        configuration.imagePlacement = .leading
        configuration.imagePadding = 6
        configuration.cornerStyle = .capsule
        configuration.baseForegroundColor = .label
        configuration.baseBackgroundColor = .secondarySystemBackground

        button.configuration = configuration

        return button
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
        setupSearchController()
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



    @objc private func sortButtonTapped() {
        let sortAlert = UIAlertController(
            title: "Select Sort Option",
            message: nil,
            preferredStyle: .actionSheet)

        let defaultOrderAction = UIAlertAction(
            title: "Default Order",
            style: .default
        ) { [weak self] _ in
            self?.selectedSort = nil
            self?.applyFilters()
        }

        sortAlert.addAction(defaultOrderAction)

        for sortOption in SortOption.allCases {
            let sortAction = UIAlertAction(
                title: sortOption.displayTitle,
                style: .default
            ) { [weak self] _ in
                self?.selectedSort = sortOption
                self?.applyFilters()
            }

            sortAlert.addAction(sortAction)
        }

        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel
        )

        sortAlert.addAction(cancelAction)


        if let popover = sortAlert.popoverPresentationController {
            popover.sourceView = sortButton
            popover.sourceRect = sortButton.bounds
        }


        present(sortAlert, animated: true)

    }


    @objc private func categoryButtonTapped() {
        let alert = UIAlertController(
            title: "Select Category",
            message: nil,
            preferredStyle: .actionSheet
        )

        let allCategoriesAction = UIAlertAction(
            title: "All Categories",
            style: .default
        ) { [weak self] _ in
            self?.selectedCategory = nil
            self?.applyFilters()
        }

        alert.addAction(allCategoriesAction)

        for category in availableCategories {
            let categoryAction = UIAlertAction(
                title: category,
                style: .default
            ) { [weak self] _ in
                self?.selectedCategory = category
                self?.applyFilters()
            }

            alert.addAction(categoryAction)
        }

        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel
        )

        alert.addAction(cancelAction)


        if let popover = alert.popoverPresentationController {
            popover.sourceView = categoryButton
            popover.sourceRect = categoryButton.bounds
        }

        present(alert, animated: true)
    }

    private func setupSearchController() {
        searchController.searchResultsUpdater = self

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        searchController.searchBar.placeholder = "Search products"
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

        categoryButton.addTarget(
            self,
            action: #selector(categoryButtonTapped),
            for: .touchUpInside
        )

        sortButton.addTarget(
            self,
            action: #selector(sortButtonTapped),
            for: .touchUpInside)


    }

    private func setupHierarchy() {
        view.addSubview(collectionView)
        view.addSubview(loadingIndicator)
        view.addSubview(emptyStateLabel)
        view.addSubview(errorLabel)
        view.addSubview(categoryButton)
        view.addSubview(sortButton)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            categoryButton.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 8
            ),
            categoryButton.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 16
            ),
            categoryButton.heightAnchor.constraint(
                equalToConstant: 36
            ),

            collectionView.topAnchor.constraint(
                equalTo: categoryButton.bottomAnchor,
                constant: 12
            ),
            sortButton.topAnchor.constraint(
                equalTo: categoryButton.topAnchor
            ),
            sortButton.leadingAnchor.constraint(
                equalTo: categoryButton.trailingAnchor,
                constant: 8
            ),
            sortButton.heightAnchor.constraint(
                equalTo: categoryButton.heightAnchor
            ),

            collectionView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor
            ),
            collectionView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor
            ),
            collectionView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            ),

            loadingIndicator.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            loadingIndicator.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),

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
            ),

            errorLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            errorLabel.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),
            errorLabel.leadingAnchor.constraint(
                greaterThanOrEqualTo: view.leadingAnchor,
                constant: 24
            ),
            errorLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: view.trailingAnchor,
                constant: -24
            )
        ])
    }

    private func loadProducts() {
        showLoading()

        Task {
            do {
                let fetchedProducts = try await productService.fetchProducts()

                self.originalProducts = fetchedProducts

                let categories = fetchedProducts.map { product in
                    product.category
                }

                let uniqueCategories = Set(categories)
                self.availableCategories = uniqueCategories.sorted()

                self.displayedProducts = fetchedProducts
                self.collectionView.reloadData()

                if fetchedProducts.isEmpty {
                    self.showEmpty()
                } else {
                    self.showProducts()
                }
            } catch let error {
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

    private func applyFilters() {
        var filteredProducts = originalProducts

        let normalizedSearchText = (searchController.searchBar.text ?? "")
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
                filteredProducts = filteredProducts.sorted {
                    $0.price < $1.price
                }

            case .priceDescending:
                filteredProducts = filteredProducts.sorted {
                    $0.price > $1.price
                }

            case .titleAscending:
                filteredProducts = filteredProducts.sorted {
                    $0.title.lowercased() < $1.title.lowercased()
                }

            case .titleDescending:
                filteredProducts = filteredProducts.sorted {
                    $0.title.lowercased() > $1.title.lowercased()
                }
            }
        }

        displayedProducts = filteredProducts
        collectionView.reloadData()

        if displayedProducts.isEmpty {
            emptyStateLabel.text = "No products match your current filters."
            showEmpty()
        } else {
            showProducts()
        }
    }
}

// MARK: - UISearchResultsUpdating

extension ProductListViewController: UISearchResultsUpdating {

    func updateSearchResults(
        for searchController: UISearchController
    ) {
        applyFilters()
    }
}

// MARK: - UICollectionViewDataSource

extension ProductListViewController: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        displayedProducts.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let product = displayedProducts[indexPath.item]

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
        UIEdgeInsets(
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
        16
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        12
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let selectedProduct = displayedProducts[indexPath.item]

        onProductSelected?(selectedProduct)
    }
}
