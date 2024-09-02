//
//  SettingsCoordinator.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 3/28/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import UIKit
import MessageUI
//import SwiftyAcknowledgements

final class SettingsCoordinator: NSObject, CoordinatorType {
    let identifier = "settings"
    var subcoordinators: [CoordinatorType] = []
    var rootViewController: UIViewController
    required init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }
    var navController: UINavigationController!

    weak var delegate: SettingsCoordinatorDelegate?

    func start() {
        let settingsRoot = SettingsRootViewController()
        settingsRoot.delegate = self
        navController = UINavigationController(rootViewController: settingsRoot)
        navController.modalPresentationStyle = .fullScreen
        rootViewController.present(navController, animated: true)
    }
}

extension SettingsCoordinator: SettingsRootViewControllerDelegate {
    func settingsRootViewControllerOpenSubscriptionManagement(_ viewController: SettingsRootViewController) {
        UIApplication.shared.open(URL(string: "https://apps.apple.com/account/subscriptions")!)
    }

    func settingsRootViewControllerSignOut(_ viewController: SettingsRootViewController) {
        UserDefaults.standard.set(nil, forKey: "auth_token")
        delegate?.settingsCoordinatorDidSignOut(self)
    }

    func settingsRootViewControllerOpenAccountSettings(_ viewController: SettingsRootViewController) {
        navController.present(LoadingIndicatorView(), animated: true)
        User.currentUser!.getUserInfo { result in
            switch result {
            case .success(let userInfo):
                DispatchQueue.main.async { [unowned self] in
                    self.navController.dismiss(animated: true) {
                        let accountSettings = AccountSettingsViewController(userInfo: userInfo)
                        accountSettings.delegate = self
                        self.navController.show(accountSettings, sender: self)
                    }
                }
            case .failure(let error):
                NetworkProvider().handle(error)
            }
        }
    }

    func settingsRootViewControllerOpenTransactionsList(_ viewController: SettingsRootViewController) {
        NetworkProvider().requestAndHandleError(.getTransactions, in: viewController) { [unowned self] (items: [OrderHistoryItem]) in
            if items.count == 0 {
                let noTransactions = NoTransactionsViewController()
                self.navController.show(noTransactions, sender: self)
            } else {
                let transactionsList = TransactionsListViewController(items: items)
                transactionsList.delegate = self
                self.navController.show(transactionsList, sender: self)
            }
        }
    }

    func settingsRootViewController(_ viewController: SettingsRootViewController,
                                    openWhoWeAreScreenFor option: SettingsRootViewController.WhoWeAreOption) {
        switch option {
        case .pourMikeys:
            let pourMikeys = AboutPourMikeysViewController()
            pourMikeys.delegate = self
            navController.show(pourMikeys, sender: self)
        case .kingsmenCafe:
            break
        }
    }

    func settingsRootViewControllerOpenThirdPartyAcknowledgements(_ viewController: SettingsRootViewController) {
//        let librariesViewController = AcknowledgementsTableViewController()
//        navController.show(librariesViewController, sender: self)
    }

    func settingsRootViewControllerDidFinish(_ viewController: SettingsRootViewController) {
        rootViewController.dismiss(animated: true)
        delegate?.settingsCoordinatorDidCloseSettings(self)
    }

}

extension SettingsCoordinator: AccountSettingsViewControllerDelegate {
    func accountSettingsViewControllerDidSelectSignOut(_ viewController: AccountSettingsViewController) {
        UserDefaults.standard.set(nil, forKey: "auth_token")
        delegate?.settingsCoordinatorDidSignOut(self)
    }

    func accountSettingsViewController(_ viewController: AccountSettingsViewController, resetPasswordWith email: String) {
        NetworkProvider().requestAndHandleError(.forgotPassword(email: email), in: viewController) { (message: BackendMessage) in
            let alert = UIAlertController(title: "Reset Password", message: message.displayMessage, preferredStyle: .alert)
            alert.addAction(
                UIAlertAction(title: "OK", style: .default, handler: { [unowned self] _ in
                    self.navController.popViewController(animated: true)
                })
            )
            viewController.present(alert, animated: true)
        }
    }

    func accountSettingsViewController(_ viewController: AccountSettingsViewController, update userInfo: UserInfo) {
        NetworkProvider().requestAndHandleError(.updateInfo(userInfo: userInfo),
                                                in: viewController) { [rootViewController, delegate] (newInfo: UserInfo) in
            rootViewController.dismiss(animated: true) {
                delegate?.settingsCoordinator(self, didUpdateUserInfoWith: newInfo)
            }
        }
    }
}

extension SettingsCoordinator: TransactionsListViewControllerDelegate {
    func transactionsListViewController(_ viewController: TransactionsListViewController, openTransaction order: OrderHistoryItem) {
        let viewController = TransactionDetailViewController(order: order)
        viewController.delegate = self
        navController.show(viewController, sender: self)
    }
}

extension SettingsCoordinator: TransactionDetailViewControllerDelegate {
    func transactionDetailViewController(_ viewController: TransactionDetailViewController, addItemsToCartFrom order: OrderHistoryItem) {
        Cart.shared.clear()
        delegate?.settingsCoordinator(self, openCartWith: order)
    }

    func transactionDetailViewController(_ viewController: TransactionDetailViewController, sendFeedbackOn order: OrderHistoryItem) {
        // make api for this
        // send mail to mikey@pourmikeyscoffee.com
        if MFMailComposeViewController.canSendMail() {
            let mailController = MFMailComposeViewController()
            mailController.setToRecipients(["mikey@pourmikeyscoffee.com"])
            mailController.setCcRecipients(["mwyskiel@kingsmen.org"])
            mailController.setSubject("Feedback - Order #" + order.transaction.orderId)
            mailController.addAttachmentData(try! JSONEncoder().encode(order),
                                             mimeType: "application/json",
                                             fileName: order.transaction.orderId + ".json")
            mailController.setMessageBody("Please enter your feedback below:\n\n", isHTML: false)
            mailController.mailComposeDelegate = self
            viewController.present(mailController, animated: true)
        } else {
            // swiftlint:disable line_length
            let urlString = "mailto:mikey@pourmikescoffee.com?cc=mwyskiel@kingsmen.org&subject=Feedback%20-%20Order%20#\(order.transaction.orderId)&body=Please%20enter%20your%20feedback%20below%3A%0A%0A"
            // swiftlint:enable line_length
            let url = URL(string: urlString)!
            UIApplication.shared.open(url)
        }
    }
}

extension SettingsCoordinator: AboutPourMikeysViewControllerDelegate {
    func aboutPourMikeysViewController(_ viewController: AboutPourMikeysViewController, open link: AboutPourMikeysView.Link) {
        let url = URL(string: link.rawValue)!
        UIApplication.shared.open(url)
    }
}

extension SettingsCoordinator: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            controller.presentingViewController!.dismiss(animated: true)
        case .saved:
            controller.presentingViewController!.dismiss(animated: true)
        case .sent:
            controller.presentingViewController!.dismiss(animated: true)
        case .failed:
            let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                controller.presentingViewController!.dismiss(animated: true)
            }))
            controller.present(alert, animated: true)
        @unknown default:
            fatalError()
        }
    }
}

protocol SettingsCoordinatorDelegate: class {
    func settingsCoordinatorDidSignOut(_ coordinator: SettingsCoordinator)
    func settingsCoordinator(_ coordinator: SettingsCoordinator, didUpdateUserInfoWith newInfo: UserInfo)
    func settingsCoordinatorDidCloseSettings(_ coordinator: SettingsCoordinator)
    func settingsCoordinator(_ coordinator: SettingsCoordinator, openCartWith order: OrderHistoryItem)
}
