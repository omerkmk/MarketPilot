//
//  ProductListViewController.swift
//  MarketPilot
//
//  Created by ömer kumek on 22.05.2026.
//

import UIKit

final class ProductListViewController: UIViewController {
    private let products : [Product] = [
        Product(id: 1, title: "MacBook M4 air ", price: 65000, imageName: nil),
        Product(id: 2, title: "Iphone 17", price: 120000, imageName: nil),
        Product(id: 3, title: "Lenovo", price: 100000, imageName: nil),
        Product(id: 4, title: "Food", price: 1000, imageName: nil),
        Product(id: 5, title: "AirPods pro", price: 10000, imageName: nil),
        Product(id: 6, title: "Computer", price: 10000, imageName: nil),
        
    ]
 
    private let emptyStateLabel = UILabel()
    private let collectionView : UICollectionView = {
        let layout  = UICollectionViewFlowLayout()
        let  collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupHierarchy()
        setupLayout()
        
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "Products"
        // emptyStateLabel
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.text = "Products will appear here"
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.textColor = .secondaryLabel
        emptyStateLabel.font = .preferredFont(forTextStyle: .body)
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.isHidden = true
        // Collection view
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ProductCollectionViewCell.self, forCellWithReuseIdentifier:ProductCollectionViewCell.reuseIdentifier)
        
        
        
    }
    
    private func setupHierarchy() {
        view.addSubview(emptyStateLabel)
        view.addSubview(collectionView)
        
        
    }
    
    private func setupLayout(){
        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),
            // Collection View Constraint
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            
            
            
        ])}
}

extension ProductListViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let product = products[indexPath.item]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCollectionViewCell.reuseIdentifier, for:indexPath) as? ProductCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(with:product)
        
        return cell
    }
}

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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItem = indexPath.item
        print("Selected item: \(selectedItem)")
    }
}
