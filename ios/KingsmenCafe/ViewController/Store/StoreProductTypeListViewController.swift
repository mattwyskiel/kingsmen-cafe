//
//  StoreProductTypeListViewController.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 3/29/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import UIKit
import Kingfisher

final class StoreProductTypeListViewController: UICollectionViewController {

    var productTypes: [SquareCatalogItem]
    weak var delegate: StoreProductTypeListViewControllerDelegate?
    let flowLayout = UICollectionViewFlowLayout()

    init(productTypes: [SquareCatalogItem]) {
        self.productTypes = productTypes
        super.init(collectionViewLayout: flowLayout)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib.init(nibName: "StoreProductTypeCell", bundle: .main)
        collectionView?.register(nib, forCellWithReuseIdentifier: "productTypeCell")
        collectionView?.reloadData()

        flowLayout.itemSize = CGSize(width: view.bounds.width / 2 - 15, height: view.bounds.width / 2 - 15)
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        flowLayout.minimumLineSpacing = 5
        collectionView?.backgroundColor = .white

        let close = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close(_:)))
        navigationItem.leftBarButtonItem = close

        title = "Product Categories"
    }

    @objc func close(_ sender: Any) {
        delegate?.productTypeListViewControllerDidFinish(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productTypes.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productTypeCell", for: indexPath) as! StoreProductTypeCell
        let productType = productTypes[indexPath.item]

        cell.imageView.kf.setImage(with: productType.itemData.imageUrl, placeholder: #imageLiteral(resourceName: "pourmikeys"))
        cell.typeLabel.text = productType.itemData.name
        cell.backgroundColor = .white
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        delegate?.storeProductTypeListViewController(self, didSelect: productTypes[indexPath.item])
    }

    override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = self.collectionView(collectionView, cellForItemAt: indexPath) as! StoreProductTypeCell
        cell.backgroundColor = .lightGray
    }

    override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = self.collectionView(collectionView, cellForItemAt: indexPath) as! StoreProductTypeCell
        cell.backgroundColor = .white
    }
}

protocol StoreProductTypeListViewControllerDelegate: class {
    func storeProductTypeListViewController(_ controller: StoreProductTypeListViewController, didSelect item: SquareCatalogItem)
    func productTypeListViewControllerDidFinish(_ controller: StoreProductTypeListViewController)
}
