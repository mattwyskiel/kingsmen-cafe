//
//  AppCoordinator.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 2/15/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import UIKit
import SafariServices
import AlertBar
import Instabug

protocol CoordinatorType: class {
    var identifier: String { get }
    var subcoordinators: [CoordinatorType] { get set }
    var rootViewController: UIViewController { get set }
    init(rootViewController: UIViewController)
    func start()
}

final class AppCoordinator: NSObject, CoordinatorType {
    let identifier = "app"
    var subcoordinators: [CoordinatorType] = []
    var rootViewController: UIViewController
    var userType: VerifyUserResult.UserType!
    var subscriptionHandler = SubscriptionHandler()
    required init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }

    func start() {
        self.subscriptionHandler.delegate = self
        if User.isLoggedIn {
            SubscriptionManager.shared.getSubscriptionState(usingReceipt: true) { result in
                switch result {
                case .success(let state):
                    if state.isSubscribed {
                        if state.isAfterSubscription {
                            self.presentHomeViewController()
                        } else {
                            self.presentNoMoreSubscriptionViewController()
                        }
                    } else {
                        self.presentHomeViewController()
                    }
                case .failure(let error):
                    switch error {
                    case .authenticationError:
                        let welcomeCoordinator = WelcomeCoordinator(rootViewController: self.rootViewController)
                        welcomeCoordinator.delegate = self
                        welcomeCoordinator.start()
                        self.subcoordinators.append(welcomeCoordinator)
                    default:
                        self.presentNetworkErrorViewController()
                    }
                }
            }
        } else {
            let welcomeCoordinator = WelcomeCoordinator(rootViewController: rootViewController)
            welcomeCoordinator.delegate = self
            welcomeCoordinator.start()
            subcoordinators.append(welcomeCoordinator)
        }
    }

    func presentHomeViewController() {
        User.currentUser!.getUserInfo { result in
            switch result {
            case .success(let user):
                self.userType = user.userType

                if self.userType == .student {

                    self.getCurrentClass { classResponse, termResponse in
                        DispatchQueue.main.async {
                            let homeViewController = HomeViewController(userInfo: user, currentClass: classResponse, currentTerm: termResponse)
                            homeViewController.delegate = self
                            homeViewController.modalTransitionStyle = .crossDissolve
                            homeViewController.modalPresentationStyle = .fullScreen
                            self.rootViewController.present(homeViewController, animated: true)

                            Instabug.identifyUser(withEmail: user.email, name: user.firstName + " " + user.lastName)
                        }
                    }

                } else {
                    DispatchQueue.main.async {
                        let homeViewController = HomeViewController(userInfo: user, currentClass: nil, currentTerm: nil)
                        homeViewController.delegate = self
                        homeViewController.modalTransitionStyle = .crossDissolve
                        homeViewController.modalPresentationStyle = .fullScreen
                        self.rootViewController.present(homeViewController, animated: true)

                        Instabug.identifyUser(withEmail: user.email, name: user.firstName + " " + user.lastName)
                    }
                }

            case .failure(let error):
                switch error {
                case .authenticationError:
                    let welcomeCoordinator = WelcomeCoordinator(rootViewController: self.rootViewController)
                    welcomeCoordinator.delegate = self
                    welcomeCoordinator.start()
                    self.subcoordinators.append(welcomeCoordinator)
                default:
                    let alert = UIAlertController(title: "Error", message: "There was a network error. (\(error.localizedDescription))",
                        preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { _ in
                        self.presentHomeViewController()
                    }))
                }
            }
        }
    }

    func getCurrentClass(_ completion: @escaping (ScheduleClassResponse?, ScheduleTermResponse) -> Void) {
        let networkProvider = NetworkProvider()
        let today = Date()
        networkProvider.request(.currentTerm(currentDate: today)) { (termResult: NetworkProvider.Result<ScheduleTermResponse>) in
            switch termResult {
            case .success(let termResponse):
                switch termResponse.term {
                case .sem1, .sem2, .winterim:
                    networkProvider.request(.getCurrentOrNextClass(currentDate: today, term: termResponse.term)) { (classResult: NetworkProvider.Result<ScheduleClassResponse>) in
                        switch classResult {
                        case .success(let classResponse):
                            completion(classResponse, termResponse)
                        case .failure(let error):
                            print(error)
                            completion(nil, termResponse)
                        }
                    }
                default:
                    completion(nil, termResponse)
                }
            case .failure(let error):
                print(error)
                completion(nil, ScheduleTermResponse(term: .sem1, startDate: nil))
            }
        }
    }

    func presentSubscriptionViewController(for state: SubscriptionManager.SubscriptionState) {
        let productID = SubscriptionManager.shared.productIdentifier(for: state.userType,
                                                                                 isBetaTester: state.isBetaTester,
                                                                                 isInBusinessClass: state.isInBusinessClass)
        SubscriptionManager.shared.fetchProduct(for: productID, completion: { [unowned self] (product) in
            let prodViewController: InAppPurchasingViewController
            if SubscriptionManager.shared.productIsSubscription(product) {
                prodViewController = SubscriptionViewController(subscription: product,
                                                                isEligibleForIntroductoryPrice: state.isEligibleForIntroductoryPricing)
            } else {
                prodViewController = OneTimePurchaseViewController(subscription: product,
                                                                   isEligibleForIntroductoryPrice: state.isEligibleForIntroductoryPricing)
            }
            prodViewController.delegate = self.subscriptionHandler
            self.rootViewController.present(prodViewController, animated: true)
        })
    }

    func presentNoMoreSubscriptionViewController() {
        let nmsViewController = NoMoreSubscriptionViewController()
        nmsViewController.delegate = self
        let navController = UINavigationController(rootViewController: nmsViewController)
        rootViewController.present(navController, animated: true)
    }

    func presentNetworkErrorViewController() {
        let networkViewController = NetworkErrorViewController()
        networkViewController.delegate = self
        let navController = UINavigationController(rootViewController: networkViewController)
        navController.modalPresentationStyle = .fullScreen
        rootViewController.present(navController, animated: true)
    }
}

extension AppCoordinator: SubscriptionHandlerDelegate {
    func subscriptionHandlerContinueAfterSuccessfulPurchase(with viewController: InAppPurchasingViewController) {
        rootViewController.dismissInMainQueue {
            self.presentHomeViewController()
        }
    }
}

extension AppCoordinator: NetworkErrorViewControllerDelegate {
    func networkErrorViewControllerDidSelectRetry(_ viewController: NetworkErrorViewController) {
        rootViewController.dismiss(animated: true)
        start()
    }
}

extension AppCoordinator: WelcomeCoordinatorDelegate {
    func welcomeCoordinatorDidComplete(welcomeCoordinator: WelcomeCoordinator) {
        rootViewController.dismiss(animated: true) {
            self.subcoordinators.delete(element: welcomeCoordinator)
            self.presentHomeViewController() // in WelcomeCoordinator, save login token √
        }
    }
}

extension AppCoordinator: HomeViewControllerDelegate {
    func homeViewController(_ viewController: HomeViewController, open quickLink: QuickLink) {
        let webView = SFSafariViewController(url: quickLink.url)
        viewController.present(webView, animated: true)
    }

    func homeViewControllerOpenSettings(_ viewController: HomeViewController) {
        let settingsCoordinator = SettingsCoordinator(rootViewController: viewController)
        settingsCoordinator.delegate = self
        settingsCoordinator.start()
        subcoordinators.append(settingsCoordinator)
    }

    func homeViewControllerOpenStore(_ viewController: HomeViewController) {
        NetworkProvider().requestAndHandleError(.storeCatalog(type: .taxes, userType: nil),
                                                in: viewController,
                                                errorVisualMessage: "There was a server error. Please try again."
        ) { [unowned self] (taxes: [SquareCatalogTax]) in
            var tax: SquareCatalogTax?
            for taxx in taxes where taxx.taxData.percentage != "0.0" {
                tax = taxx // guaranteed only one
            }
            Cart.shared.tax = tax
            let storeCoordinator = StoreCoordinator(rootViewController: viewController)
            storeCoordinator.userType = self.userType
            storeCoordinator.delegate = self
            storeCoordinator.start()
            self.subcoordinators.append(storeCoordinator)
        }
    }

    func homeViewControllerPresentCashAppInfo(_ viewController: HomeViewController) {
        // Present Cash App Info
        let webView = SFSafariViewController(url: URL(string: "https://kingsmencafe.com/about-the-app")!)
        viewController.present(webView, animated: true)
    }
}

extension AppCoordinator: SettingsCoordinatorDelegate {
    func settingsCoordinatorDidSignOut(_ coordinator: SettingsCoordinator) {
        subcoordinators.delete(element: coordinator)
        rootViewController.dismiss(animated: true) {
            self.start()
        }
    }

    func settingsCoordinator(_ coordinator: SettingsCoordinator, didUpdateUserInfoWith newInfo: UserInfo) {
        subcoordinators.delete(element: coordinator)
        let homeViewController = rootViewController.presentedViewController as! HomeViewController
        homeViewController.userInfo = newInfo
    }

    func settingsCoordinatorDidCloseSettings(_ coordinator: SettingsCoordinator) {
        subcoordinators.delete(element: coordinator)
    }

    func settingsCoordinator(_ coordinator: SettingsCoordinator, openCartWith order: OrderHistoryItem) {
        let homeViewController = rootViewController.presentedViewController as! HomeViewController
        homeViewController.dismiss(animated: true)
        subcoordinators.delete(element: coordinator)

        NetworkProvider().requestAndHandleError(.searchCatalog(fromOrder: order.checkout.order),
                                                in: homeViewController) { (results: [StoreCatalogSearchResult]) in
            let cartItems = results.enumerated().map { (index, result) in
                return CartItem(searchResult: result, quantity: order.checkout.order.lineItems[index].quantity)
            }
            Cart.shared.items = cartItems
            self.homeViewControllerOpenStore(homeViewController)
        }
    }
}

extension AppCoordinator: StoreCoordinatorDelegate {
    func storeCoordinatorPreOrderDidCancel(_ browseCoordinator: StoreCoordinator) {
        let homeViewController = rootViewController.presentedViewController as! HomeViewController
        homeViewController.dismiss(animated: true)
        subcoordinators.delete(element: browseCoordinator)
    }

    func storeCoordinatorPreOrderDidFinish(_ storeCoordinator: StoreCoordinator) {
        subcoordinators.delete(element: storeCoordinator)
    }
}

extension AppCoordinator: NoMoreSubscriptionViewControllerDelegate {
    func goToSettings() {
        UIApplication.shared.open(URL(string: "https://apps.apple.com/account/subscriptions")!)
        rootViewController.dismissInMainQueue {
            self.presentHomeViewController()
        }
    }
}

extension AppCoordinator {
    func showOrderConfirmation() {
        if let storeCoordinator: StoreCoordinator = subcoordinators["store"] {
            storeCoordinator.showOrderConfirmation()
        } else {
            fatalError()
        }
    }
    func sendSupportEmail(subject: String, body: String) {
        let data = body.data(using: .utf8)!
        Instabug.willSendReportHandler = { report in
            report.addFileAttachment(with: data)
            return report
        }
        BugReporting.didDismissHandler = { _, _ in
            Instabug.clearFileAttachments()
            if let storeCoordinator: StoreCoordinator = self.subcoordinators["store"] {
                storeCoordinator.dismissCheckoutConfirmationViewController()
            }
        }
        BugReporting.show(with: .feedback, options: [.emailFieldOptional, .commentFieldRequired])
    }
}
