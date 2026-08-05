//
//  CartItemCell.swift
//  MarketPilot
//
//  Created by ömer kumek on 4.08.2026.
//

import UIKit

final class CartItemCell: UITableViewCell {
    
    static let reuseIdentifier = "CartItemCell"
    var onDecreaseTapped: (() -> Void)?
    
    private func setupAction(){
        decreaseButton.addTarget(self, action: #selector(decreaseButtonTapped), for: .touchUpInside)
    
    }
    
    @objc func decreaseButtonTapped(){
        
         onDecreaseTapped?()
    }
    
    private let productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .headline)
        label.numberOfLines = 2
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let quantityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .label
        return label
    }()
    
    private let decreaseButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(
            UIImage(systemName: "minus.circle"),
            for: .normal
        )
        return button
    }()
    
    private let increaseButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(
            UIImage(systemName: "plus.circle"),
            for: .normal
        )
        return button
    }()
    
    
    func configure(with cartItem: CartItem) {
        titleLabel.text = cartItem.product.title
        priceLabel.text = String(
            format: "$%.2f",
            cartItem.product.price
        )
        quantityLabel.text = "Quantity: \(cartItem.quantity)"
    }
    
    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupHierarchy()
        setupLayout()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupHierarchy() {
        contentView.addSubview(productImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(quantityLabel)
        contentView.addSubview(decreaseButton)
        contentView.addSubview(increaseButton)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            productImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16
            ),
            productImageView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 12
            ),
            productImageView.bottomAnchor.constraint(
                lessThanOrEqualTo: contentView.bottomAnchor,
                constant: -12
            ),
            productImageView.widthAnchor.constraint(equalToConstant: 88),
            productImageView.heightAnchor.constraint(equalToConstant: 88),
            
            titleLabel.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 12
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: productImageView.trailingAnchor,
                constant: 12
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16
            ),
            
            priceLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 8
            ),
            priceLabel.leadingAnchor.constraint(
                equalTo: titleLabel.leadingAnchor
            ),
            priceLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16
            ),
            quantityLabel.topAnchor.constraint(
                equalTo: priceLabel.bottomAnchor,
                constant: 6
            ),
           
            
            quantityLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -12
            ),
            
            decreaseButton.leadingAnchor.constraint(
                equalTo: titleLabel.leadingAnchor
            ),
            decreaseButton.centerYAnchor.constraint(
                equalTo: quantityLabel.centerYAnchor
            ),
            decreaseButton.widthAnchor.constraint(equalToConstant: 28),
            decreaseButton.heightAnchor.constraint(equalToConstant: 28),

            quantityLabel.leadingAnchor.constraint(
                equalTo: decreaseButton.trailingAnchor,
                constant: 8
            ),
            
            increaseButton.leadingAnchor.constraint(
                equalTo: quantityLabel.trailingAnchor,
                constant: 8
            ),
            increaseButton.centerYAnchor.constraint(
                equalTo: quantityLabel.centerYAnchor
            ),
            increaseButton.widthAnchor.constraint(equalToConstant: 28),
            increaseButton.heightAnchor.constraint(equalToConstant: 28),
            increaseButton.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16
            )
        ])
    }
    
    
   
    
    
    
}
