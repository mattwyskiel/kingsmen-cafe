//
//  StoreCoordinator.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 4/5/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import UIKit
import SafariServices
import AlertBar

final class StoreCoordinator: CoordinatorType {
    let identifier = "store"
    var subcoordinators: [CoordinatorType] = []
    var rootViewController: UIViewController
    var navController: UINavigationController!
    var userType: VerifyUserResult.UserType!

    weak var delegate: StoreCoordinatorDelegate?

    required init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }

    func start() {
        let cartView = CartViewController(style: .plain)
        cartView.delegate = self
        navController = UINavigationController(rootViewController: cartView)
        navController.modalPresentationStyle = .fullScreen
        rootViewController.present(navController, animated: true) { [unowned self] in
            if Cart.shared.items.count == 0 {
                self.presentProductBrowser()
            }
        }
    }
}

extension StoreCoordinator: CartViewControllerDelegate {
    func cartViewControllerDidSelectAddItem(_ viewController: CartViewController) {
        presentProductBrowser()
    }

    func presentProductBrowser() {
        let browseCoordinator = ProductBrowseCoordinator(rootViewController: navController)
        browseCoordinator.userType = userType
        browseCoordinator.delegate = self
        browseCoordinator.start()
        subcoordinators.append(browseCoordinator)
    }

    func cartViewControllerDidSelectCheckOut(_ viewController: CartViewController) {
        // check out
        NetworkProvider().requestAndHandleError(.checkout(items: Cart.shared.items, taxIDs: [Cart.shared.tax!]),
                                                in: navController) { [navController] (response: CheckoutResponse) in
            let url = response.checkoutURL
            let safariController = SFSafariViewController(url: url)
            navController?.show(safariController, sender: self)
        }
    }

    func cartViewControllerDidCancel(_ viewController: CartViewController) {
        delegate?.storeCoordinatorPreOrderDidCancel(self)
    }
}

extension StoreCoordinator: ProductBrowseCoordinatorDelegate {
    func browseCoordinator(_ coordinator: ProductBrowseCoordinator, addItemToCart cartItem: CartItem) {
        Cart.shared.items.append(cartItem)
        subcoordinators.delete(element: coordinator)
    }
}

extension StoreCoordinator: CheckoutConfirmationViewControllerDelegate {
    func showOrderConfirmation() {
        let viewController = CheckoutConfirmationViewController()
        viewController.delegate = self
        navController.show(viewController, sender: self)
    }

    func checkoutConfirmationViewControllerDidFinish(_ controller: CheckoutConfirmationViewController) {
        rootViewController.dismiss(animated: true) { [unowned self] in
            self.delegate?.storeCoordinatorPreOrderDidFinish(self)
        }
    }
    func dismissCheckoutConfirmationViewController() {
        rootViewController.dismiss(animated: true) { [unowned self] in
            self.delegate?.storeCoordinatorPreOrderDidFinish(self)
        }
    }
}

protocol StoreCoordinatorDelegate: class {
    func storeCoordinatorPreOrderDidCancel(_ storeCoordinator: StoreCoordinator)
    func storeCoordinatorPreOrderDidFinish(_ storeCoordinator: StoreCoordinator)
}
