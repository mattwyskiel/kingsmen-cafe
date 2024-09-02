//
//  VerifyUserViewController.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 3/17/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//
// swiftlint:disable large_tuple

import UIKit
import SkyFloatingLabelTextField
import PMSuperButton

final class VerifyUserViewController: UIViewController {

    weak var delegate: VerifyUserViewControllerDelegate?

    @IBOutlet weak var valueTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var submitButton: PMSuperButton!

    var regularContentInsets: UIEdgeInsets!

    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        regularContentInsets = scrollView.adjustedContentInset
        registerForKeyboardNotifications()
    }

    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown(_:)), name: .UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeHidden(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func dismissKeyboard(_ sender: Any) {
        view.endEditing(true)
    }

    var verifyKey: VerifyUserKey = .email
    let verifyKeys: [String: (VerifyUserKey, String, UIKeyboardType, UITextContentType)] = [
        "RenWeb user name": (.userName, "Username", .default, .username),
        "RenWeb-associated email": (.email, "Email", .emailAddress, .emailAddress)
    ]

    @IBOutlet weak var verifyKeySelectionButton: UIButton!
    @IBAction func changeVerifyKey(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: "This is a...", preferredStyle: .actionSheet)
        for (key, value) in verifyKeys {
            actionSheet.addAction(UIAlertAction(title: key, style: .default, handler: { _ in
                self.verifyKey = value.0
                self.verifyKeySelectionButton.setTitle(key + " ▼", for: .normal)
                self.valueTextField.placeholder = value.1
                self.valueTextField.textContentType = value.3
                self.valueTextField.keyboardType = value.2
            }))
        }

        actionSheet.popoverPresentationController?.sourceView = verifyKeySelectionButton
        actionSheet.popoverPresentationController?.sourceRect = verifyKeySelectionButton.frame

        present(actionSheet, animated: true)
    }

    @IBAction func submit(_ sender: Any) {
        if let value = valueTextField.text {
            valueTextField.lineColor = .black
            delegate?.verifyUserViewController(self, submitWithKey: verifyKey, value: value)
        } else {
            valueTextField.lineColor = .red
        }
    }
}

extension VerifyUserViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        submit(textField)
        return true
    }
//
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        let newOffset = CGPoint(x: 0, y: textField.frame.origin.y-(textField.frame.height + 16))
//        scrollView.setContentOffset(newOffset, animated: true)
//        return true
//    }
}

extension VerifyUserViewController {
    @objc func keyboardWasShown(_ notification: Notification) {
        let kbSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        // If active text field is hidden by keyboard, scroll it so it's visible
        // Your app might not need or want this behavior.
        var aRect: CGRect = view.frame
        let obfuscated = kbSize.height + view.safeAreaInsets.bottom
        aRect.size.height -= obfuscated
        var frameOrigin = submitButton.frame.origin
        frameOrigin.y += submitButton.frame.height
        if !aRect.contains(frameOrigin) {
            scrollView.scrollRectToVisible(submitButton.frame, animated: true)
        }
    }
    @objc func keyboardWillBeHidden(_ notification: Notification) {
        scrollView.contentInset = regularContentInsets
        scrollView.scrollIndicatorInsets = regularContentInsets
        scrollView.scrollToTop()
    }

}

protocol VerifyUserViewControllerDelegate: class {
    func verifyUserViewController(_ viewController: VerifyUserViewController, submitWithKey key: VerifyUserKey, value: String)
}
