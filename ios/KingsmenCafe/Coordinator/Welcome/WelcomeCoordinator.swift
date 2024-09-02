//
//  WelcomeCoordinator.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 3/13/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import UIKit

final class WelcomeCoordinator: CoordinatorType {
    func start() {
        let welcomeViewController = WelcomeViewController()
        welcomeViewController.delegate = self
        welcomeNavController = UINavigationController(rootViewController: welcomeViewController)
        rootViewController.present(welcomeNavController, animated: true)
    }

    let identifier = "welcome"
    var subcoordinators: [CoordinatorType] = []
    var rootViewController: UIViewController
    var welcomeNavController: UINavigationController!

    required init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }
    weak var delegate: WelcomeCoordinatorDelegate?
}

extension WelcomeCoordinator: WelcomeViewControllerDelegate {
    func welcomeViewControllerDidSelectGetStarted(_ viewController: WelcomeViewController) {
        let getStartedCoordinator = GetStartedCoordinator(rootViewController: welcomeNavController)
        getStartedCoordinator.delegate = self
        subcoordinators.append(getStartedCoordinator)
        getStartedCoordinator.start()
    }

    func welcomeViewControllerDidSelectSignIn(_ viewController: WelcomeViewController) {
        let signInCoordinator = SignInCoordinator(rootViewController: welcomeNavController)
        signInCoordinator.delegate = self
        subcoordinators.append(signInCoordinator)
        signInCoordinator.start()
    }
}

extension WelcomeCoordinator: SignInCoordinatorDelegate {
    func signInCoordinatorDidComplete(_ coordinator: SignInCoordinator) {
        self.delegate?.welcomeCoordinatorDidComplete(welcomeCoordinator: self)
    }
}

extension WelcomeCoordinator: GetStartedCoordinatorDelegate {
    func getStartedCoordinatorDidFinish(_ coordinator: GetStartedCoordinator) {
        self.delegate?.welcomeCoordinatorDidComplete(welcomeCoordinator: self)
    }

}

protocol WelcomeCoordinatorDelegate: class {
    func welcomeCoordinatorDidComplete(welcomeCoordinator: WelcomeCoordinator)
}
