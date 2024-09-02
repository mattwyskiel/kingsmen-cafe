//
//  ForgotPasswordViewController.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 4/19/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

final class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var valueTextField: SkyFloatingLabelTextField!
    weak var delegate: ForgotPasswordViewControllerDelegate?

    @IBAction func submit(_ sender: Any) {
        delegate?.forgotPasswordViewController(self, submitEmailForForgottenPassword: valueTextField.text!)
    }

}

protocol ForgotPasswordViewControllerDelegate: class {
    func forgotPasswordViewController(_ viewController: ForgotPasswordViewController, submitEmailForForgottenPassword email: String)
}
