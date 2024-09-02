//
//  SignInCoordinator.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 3/15/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import UIKit

final class SignInCoordinator: CoordinatorType {
    let identifier = "signIn"
    var subcoordinators: [CoordinatorType] = []
    var rootViewController: UIViewController
    var subscriptionHandler = SubscriptionHandler()

    required init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }

    var navController: UINavigationController {
        return rootViewController as! UINavigationController
    }

    func start() {
        subscriptionHandler.delegate = self

        let signInViewController = SignInViewController()
        signInViewController.delegate = self

        navController.show(signInViewController, sender: self)
    }

    weak var delegate: SignInCoordinatorDelegate?
}

extension SignInCoordinator: SignInViewControllerDelegate {
    func signInViewControllerDidSelectForgotPassword(_ viewController: SignInViewController) {
        let forgotPassword = ForgotPasswordViewController()
        forgotPassword.delegate = self
        navController.show(forgotPassword, sender: self)
    }

    func signInViewController(_ viewController: SignInViewController, signInWithUserName userName: String, password: String) {
        NetworkProvider().requestAndHandleError(.signIn(username: userName, password: password),
                                                in: viewController) { (token: AuthToken) in
            UserDefaults.standard.setValue(token.token, forKey: "auth_token")
            self.presentNoMoreSubscriptionViewControllerIfNeeded(viewController)
        }
    }

    func presentSubscriptionViewControllerIfNeeded(_ viewController: UIViewController) {
        viewController.present(LoadingIndicatorView(), animated: true)
        SubscriptionManager.shared.getSubscriptionState { (result) in
            switch result {
            case .failure(let error):
                viewController.dismissInMainQueue {
                    NetworkProvider().handle(error)
                }
            case .success(let state):
                if state.isSubscribed {
                    viewController.dismissInMainQueue {
                        self.delegate?.signInCoordinatorDidComplete(self)
                    }
                } else {
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
                        viewController.dismissInMainQueue {
                            self.navController.show(prodViewController, sender: self)
                        }
                    })
                }
            }
        }
    }

    func presentNoMoreSubscriptionViewControllerIfNeeded(_ viewController: UIViewController) {

        func moveForward() {
            self.delegate?.signInCoordinatorDidComplete(self)
        }

        if UserDefaults.standard.bool(forKey: "hasConfirmedNoSubscription") {
            moveForward()
        } else {
            viewController.present(LoadingIndicatorView(), animated: true)
            SubscriptionManager.shared.getSubscriptionState { result in
                switch result {
                case .failure:
                    moveForward()
                case let .success(state):
                    if state.isAfterSubscription {
                        moveForward()
                    } else if state.isSubscribed {
                        let nmsViewController = NoMoreSubscriptionViewController()
                        nmsViewController.delegate = self
                        viewController.dismissInMainQueue {
                            self.navController.show(nmsViewController, sender: self)
                        }
                    } else {
                        moveForward()
                    }
                }
            }
        }
    }
}

extension SignInCoordinator: SubscriptionHandlerDelegate {
    func subscriptionHandlerContinueAfterSuccessfulPurchase(with viewController: InAppPurchasingViewController) {
        delegate?.signInCoordinatorDidComplete(self)
    }
}

extension SignInCoordinator: ForgotPasswordViewControllerDelegate {
    func forgotPasswordViewController(_ viewController: ForgotPasswordViewController, submitEmailForForgottenPassword email: String) {
        NetworkProvider().requestAndHandleError(.forgotPassword(email: email), in: viewController) { (message: BackendMessage) in
            let alert = UIAlertController(title: "Reset Password", message: message.displayMessage, preferredStyle: .alert)
            alert.addAction(
                UIAlertAction(title: "OK", style: .default, handler: { [unowned self] _ in self.navController.popViewController(animated: true)
                })
            )
            viewController.present(alert, animated: true)
        }
    }
}

extension SignInCoordinator: NoMoreSubscriptionViewControllerDelegate {
    func goToSettings() {
            UIApplication.shared.open(URL(string: "https://apps.apple.com/account/subscriptions")!)
            self.delegate?.signInCoordinatorDidComplete(self)
    }
}

protocol SignInCoordinatorDelegate: class {
    func signInCoordinatorDidComplete(_ coordinator: SignInCoordinator)
}
