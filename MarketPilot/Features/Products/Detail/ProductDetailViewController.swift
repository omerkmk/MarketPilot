//
//  ProductDetailViewController.swift
//  MarketPilot
//
//  Created by ömer kumek on 9.07.2026.
//

import UIKit

final class ProductDetailViewController: UIViewController {
    
    private let product: Product
    private let imageLoadingService: ImageLoadingServiceProtocol
    
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .title2)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .title3)
        label.textColor = .label
        return label
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()
    
    private let productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .secondarySystemBackground
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("♡ Add to Favorites", for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        return button
    }()

    private let addToCartButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Add to Cart", for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        button.backgroundColor = .label
        button.setTitleColor(.systemBackground, for: .normal)
        button.layer.cornerRadius = 12
        return button
    }()
    
    
    
    init(product: Product, imageLoadingService: ImageLoadingServiceProtocol) {
        self.product = product
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
        configure()
        loadProductImage()
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        title = product.title
        
        favoriteButton.addTarget(
            self,
            action: #selector(favoriteButtonTapped),
            for: .touchUpInside
        )

        addToCartButton.addTarget(
            self,
            action: #selector(addToCartButtonTapped),
            for: .touchUpInside
        )
        
    }
    
    private func setupHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(productImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(favoriteButton)
        contentView.addSubview(addToCartButton)
    }
    private func setupLayout() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            productImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            productImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            productImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            productImageView.heightAnchor.constraint(equalToConstant: 280),
            
            titleLabel.topAnchor.constraint(equalTo: productImageView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            categoryLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 8),
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            
            favoriteButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            favoriteButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            favoriteButton.heightAnchor.constraint(equalToConstant: 44),

            addToCartButton.topAnchor.constraint(equalTo: favoriteButton.bottomAnchor, constant: 12),
            addToCartButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            addToCartButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            addToCartButton.heightAnchor.constraint(equalToConstant: 52),
            addToCartButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        
        
        ])
    }
    
    private func configure() {
        titleLabel.text = product.title
        priceLabel.text = "$\(product.price)"
        categoryLabel.text = product.category
        descriptionLabel.text = product.description
       
    }
    
    
    private func loadProductImage() {
        guard let imageURLString = product.image else {
            return
        }
        
        Task { [weak self] in
            do {
                let image = try await self?.imageLoadingService.loadImage(from: imageURLString)
                
                await MainActor.run {
                    self?.productImageView.image = image
                    self?.productImageView.backgroundColor = .clear
                }
            } catch {
                print(error)
            }
        }
    }
    
    @objc private func favoriteButtonTapped() {
        print("Favorite tapped: \(product.title)")
    }

    @objc private func addToCartButtonTapped() {
        print("Add to cart tapped: \(product.title)")
    }
    
}
