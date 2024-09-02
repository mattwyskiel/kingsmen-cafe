//
//  WelcomeViewController.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 3/15/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import UIKit

final class WelcomeViewController: UIViewController {
    weak var delegate: WelcomeViewControllerDelegate?

    @IBAction func getStarted(_ sender: Any) {
        delegate?.welcomeViewControllerDidSelectGetStarted(self)
    }

    @IBAction func signIn(_ sender: Any) {
        delegate?.welcomeViewControllerDidSelectSignIn(self)
    }
}

protocol WelcomeViewControllerDelegate: class {
    func welcomeViewControllerDidSelectGetStarted(_ viewController: WelcomeViewController)
    func welcomeViewControllerDidSelectSignIn(_ viewController: WelcomeViewController)
}
