//
//  SignInViewController.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 3/17/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import AlertBar

final class SignInViewController: UIViewController {
    weak var delegate: SignInViewControllerDelegate?

    @IBOutlet weak var userNameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordTextField: SkyFloatingLabelTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
    }

    @objc func dismissKeyboard(_ sender: Any) {
        view.endEditing(true)
    }

    @IBAction func forgotPassword(_ sender: Any) {
        delegate?.signInViewControllerDidSelectForgotPassword(self)
    }

    @IBAction func login(_ sender: Any) {
        delegate?.signInViewController(self, signInWithUserName: userNameTextField.text!, password: passwordTextField.text!)
    }

    func handle(_ error: NetworkError) {
        switch error {
        case .badRequest(let backendError):
            AlertBar.show(type: .error, message: backendError.message)
            if let invalidField = backendError.otherInfo?["invalidField"]?.stringValue {
                switch invalidField {
                case "username":
                    userNameTextField.lineColor = .red
                case "password":
                    passwordTextField.lineColor = .black
                default:
                    break
                }
            }
        default:
            break
        }
    }

}

extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userNameTextField {
            return passwordTextField.becomeFirstResponder()
        } else {
            view.endEditing(true)
            login(textField)
            return true
        }
    }
}

protocol SignInViewControllerDelegate: class {
    func signInViewControllerDidSelectForgotPassword(_ viewController: SignInViewController)
    func signInViewController(_ viewController: SignInViewController, signInWithUserName userName: String, password: String)
}
