//
//  StoreCoordinator.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 4/1/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import UIKit

final class ProductBrowseCoordinator: CoordinatorType {
    let identifier = "product-browse"
    var subcoordinators: [CoordinatorType] = []
    var rootViewController: UIViewController
    var navController: UINavigationController!
    var userType: VerifyUserResult.UserType!

    weak var delegate: ProductBrowseCoordinatorDelegate?

    required init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }

    func start() {
        NetworkProvider().requestAndHandleError(.storeCatalog(type: .items, userType: userType),
                                                in: rootViewController) { (items: [SquareCatalogItem]) in
            let productTypeListViewController = StoreProductTypeListViewController(productTypes: items)
            productTypeListViewController.delegate = self
            self.navController = UINavigationController(rootViewController: productTypeListViewController)
            self.rootViewController.present(self.navController, animated: true)
        }
    }

}

extension ProductBrowseCoordinator: StoreProductTypeListViewControllerDelegate {
    func storeProductTypeListViewController(_ controller: StoreProductTypeListViewController, didSelect item: SquareCatalogItem) {
        // handle selection
        let detailVC = StoreProductDetailListViewController(items: item.itemData.variations,
                                                            productType: item.itemData.name,
                                                            headerImageURL: item.itemData.imageUrl)
        detailVC.delegate = self
        navController.show(detailVC, sender: self)
    }

    func productTypeListViewControllerDidFinish(_ controller: StoreProductTypeListViewController) {
        rootViewController.dismiss(animated: true)
    }
}

extension ProductBrowseCoordinator: StoreProductDetailListViewControllerDelegate {
    func storeProductDetailListViewController(_ controller: StoreProductDetailListViewController,
                                              didSelect item: SquareCatalogItem.ItemData.Variation,
                                              imageURL: URL?) {
        //temp
        let cartItem = CartItem(squareProductInfo: item, imageURL: imageURL)
        rootViewController.dismiss(animated: true) { [delegate] in
            delegate?.browseCoordinator(self, addItemToCart: cartItem)
        }
    }
}

protocol ProductBrowseCoordinatorDelegate: class {
    func browseCoordinator(_ coordinator: ProductBrowseCoordinator, addItemToCart cartItem: CartItem)
}
