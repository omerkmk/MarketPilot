//
//  ProductListViewController.swift
//  MarketPilot
//
//  Created by ömer kumek on 22.05.2026.
//

import UIKit

final class ProductListViewController: UIViewController {
    
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
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        
        
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
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = .systemBlue
        return cell
    }
}

extension ProductListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItem = indexPath.item
        print("Selected item: \(selectedItem)")
    }
}
