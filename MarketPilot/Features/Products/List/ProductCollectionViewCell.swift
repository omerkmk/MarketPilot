//
//  ProductCollectionViewCell.swift
//  MarketPilot
//
//  Created by ömer kumek on 27.05.2026.
//

import UIKit

final class ProductCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "ProductCollectionViewCell"
    private let productImageView = UIImageView()
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    private let favoriteImageView = UIImageView()
    private var currentImageURLString: String?
    private var imageLoadingTask: Task<Void, Never>?
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupHierarchy()
        setupLayout()
    }

    func configure(


    with product: Product,
    imageLoadingService: ImageLoadingServiceProtocol,
    isFavorite: Bool
    ) {

        imageLoadingTask?.cancel()
        imageLoadingTask = nil

        titleLabel.text = product.title
        priceLabel.text = "$\(product.price)"

        favoriteImageView.image = UIImage(
            systemName: isFavorite ? "heart.fill" : "heart"
        )

        guard let imageURLString = product.image else {
            productImageView.image = nil
            productImageView.backgroundColor = .systemGray5
            currentImageURLString = nil
            return
        }

        currentImageURLString = imageURLString

        imageLoadingTask = Task { [weak self] in
            do {
                let image = try await imageLoadingService.loadImage(from: imageURLString)

                await MainActor.run {
                    guard let self = self else { return }
                    guard self.currentImageURLString == imageURLString else { return }

                    self.productImageView.image = image
                    self.productImageView.backgroundColor = .clear
                }
            }
            catch is CancellationError {

            }
            catch {
                print("Image loading failed:", error)
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        // Product Image View
        productImageView.backgroundColor = .systemGray5
        productImageView.contentMode = .scaleAspectFit
        productImageView.translatesAutoresizingMaskIntoConstraints = false

        //Title Label
        titleLabel.text = "Product Title"
        titleLabel.font = .preferredFont(forTextStyle: .body)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // PriceLabel
        priceLabel.text = "$19.99"
        priceLabel.font = .preferredFont(forTextStyle: .headline)
        priceLabel.textColor = .label
        priceLabel.translatesAutoresizingMaskIntoConstraints = false

        // Favorite ImageView
        favoriteImageView.translatesAutoresizingMaskIntoConstraints = false
        favoriteImageView.contentMode = .scaleAspectFit
    }

    private func setupHierarchy() {
        contentView.addSubview(productImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(favoriteImageView)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            productImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            productImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            productImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            productImageView.heightAnchor.constraint(equalToConstant: 120),

            titleLabel.topAnchor.constraint(equalTo: productImageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),

            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            priceLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8),

            favoriteImageView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 8
            ),
            favoriteImageView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -8
            ),
            favoriteImageView.widthAnchor.constraint(
                equalToConstant: 24
            ),
            favoriteImageView.heightAnchor.constraint(
                equalToConstant: 24
            )
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadingTask?.cancel()
        imageLoadingTask = nil

        productImageView.image = nil
        productImageView.backgroundColor = .systemGray5
        currentImageURLString = nil
        favoriteImageView.image = nil

    }
}
