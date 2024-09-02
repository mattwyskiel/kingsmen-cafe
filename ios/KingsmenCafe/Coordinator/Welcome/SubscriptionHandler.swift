//
//  SubscriptionHandler.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 9/15/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import Foundation
import StoreKit
import SafariServices

class SubscriptionHandler: PurchasingViewControllerDelegate {
    var notificationTokens: [NSObjectProtocol] = []
    weak var delegate: SubscriptionHandlerDelegate?

    deinit {
        notificationTokens.forEach { NotificationCenter.default.removeObserver($0) }
    }

    func purchasingViewController(_ viewController: InAppPurchasingViewController, open url: URL) {
        let webView = SFSafariViewController(url: url)
        viewController.present(webView, animated: true)
    }

    func purchasingViewController(_ viewController: InAppPurchasingViewController, subscribeTo product: SKProduct) {
        // handle
        viewController.present(LoadingIndicatorView(), animated: true)
        SubscriptionManager.shared.purchase(product)
        let notificationToken = NotificationCenter.default.addObserver(forName: .storeTransactionMade,
                                                                       object: nil,
                                                                       queue: .main) { [unowned self] note in
            let queueAndTransaction = note.object as! PaymentQueueAndTransaction
            switch queueAndTransaction.transaction.transactionState {
            case .purchasing:
                break // do nothing
            case .purchased:
                queueAndTransaction.queue.finishTransaction(queueAndTransaction.transaction)
                self.handleSuccessfulPurchase(viewController: viewController)
            case .failed:
                queueAndTransaction.queue.finishTransaction(queueAndTransaction.transaction)
                self.handleFailedPurchase(with: queueAndTransaction.transaction.error as! SKError, viewController)
            case .restored:
                queueAndTransaction.queue.finishTransaction(queueAndTransaction.transaction)
                self.handleSuccessfulPurchase(viewController: viewController)
            case .deferred:
                self.handleDeferredPurchase(viewController)
            @unknown default:
                break // do nothing
                                                                        }
        }
        notificationTokens.append(notificationToken)
    }

    // swiftlint:disable line_length
    func handleSuccessfulPurchase(viewController: InAppPurchasingViewController) {
        viewController.present(LoadingIndicatorView(), animated: true)
        SubscriptionManager.shared.getSubscriptionState(usingReceipt: true) { result in
            switch result {
            case .success(let state):
                if state.isSubscribed {
                    viewController.dismissInMainQueue { [unowned self] in
                        self.delegate?.subscriptionHandlerContinueAfterSuccessfulPurchase(with: viewController)
                    }
                } else {
                    viewController.dismissInMainQueue { [unowned self] in
                        let alert = UIAlertController(title: "In-App Purchase Validation", message: "We have been unable to validate the receipt. This does not necessarily mean you have not bought the app, because you have. You now have full access to the app, and we will try again the next time you start the app.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                            self.delegate?.subscriptionHandlerContinueAfterSuccessfulPurchase(with: viewController)
                        }))
                        viewController.present(alert, animated: true)
                    }
                }
            case .failure:
                // if failed, allow user to go through
                viewController.dismissInMainQueue { [unowned self] in
                    let alert = UIAlertController(title: "In-App Purchase Validation", message: "We have been unable to validate the receipt. This does not necessarily mean you have not bought the app, because you have. You now have full access to the app, and we will try again the next time you start the app.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                        self.delegate?.subscriptionHandlerContinueAfterSuccessfulPurchase(with: viewController)
                    }))
                    viewController.present(alert, animated: true)
                }
            }
        }
    }
    // swiftlint:enable line_length

    func handleFailedPurchase(with error: SKError, _ viewController: InAppPurchasingViewController) {
        viewController.dismissInMainQueue {
            if error.code != .paymentCancelled {
                let alert = UIAlertController(title: "In-App Purchase Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                viewController.present(alert, animated: true)
            }
        }
    }

    func handleDeferredPurchase(_ viewController: InAppPurchasingViewController) {
        UserDefaults.standard.set(true, forKey: "purchase_deferred")
        viewController.dismissInMainQueue {
            // create view controller to present
            let alert = UIAlertController(title: "Asking to Buy",
                                          message: "Your parents have been asked permission to purchase this app. Please check in later.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            viewController.present(alert, animated: true)
        }
    }

    func purchasingViewControllerShowMoreInfo(_ viewController: InAppPurchasingViewController) {
        // handle
        let moreInfoView = SubscriptionMoreInfoViewController()
        moreInfoView.delegate = self
        let navigationController = UINavigationController(rootViewController: moreInfoView)
        navigationController.modalPresentationStyle = .formSheet
        viewController.present(navigationController, animated: true)
    }

    func purchasingViewControllerRestorePurchases(_ viewController: InAppPurchasingViewController) {
        viewController.present(LoadingIndicatorView(), animated: true)
        SubscriptionManager.shared.refreshReceipt { success in
            guard success else {
                viewController.dismiss(animated: true)
                return
            }
            SubscriptionManager.shared.getSubscriptionState(usingReceipt: true) { result in
                switch result {
                case .failure(let error):
                    viewController.dismissInMainQueue {
                        NetworkProvider().handle(error)
                    }
                case .success(let state):
                    if state.isSubscribed {
                        viewController.dismissInMainQueue {
                            self.delegate?.subscriptionHandlerContinueAfterSuccessfulPurchase(with: viewController)
                        }
                    } else {
                        viewController.dismissInMainQueue {
                            let alert = UIAlertController(title: "No Subscriptions Found",
                                                          message: "Please purchase a subscription.",
                                                          preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            viewController.present(alert, animated: true)
                        }
                    }
                }
            }
        }
    }
}

extension SubscriptionHandler: SubscriptionMoreInfoViewControllerDelegate {
    func subscriptionMoreInfoViewController(_ viewController: SubscriptionMoreInfoViewController, open url: URL) {
        let webView = SFSafariViewController(url: url)
        viewController.navigationController!.show(webView, sender: self)
    }

    func subscriptionMoreInfoViewControllerDidFinish(_ viewController: SubscriptionMoreInfoViewController) {
        viewController.navigationController!.presentingViewController!.dismiss(animated: true)
    }
}

protocol SubscriptionHandlerDelegate: class {
    func subscriptionHandlerContinueAfterSuccessfulPurchase(with viewController: InAppPurchasingViewController)
}
