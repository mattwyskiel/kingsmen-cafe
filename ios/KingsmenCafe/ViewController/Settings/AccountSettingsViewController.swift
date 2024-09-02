//
//  AccountSettingsViewController.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 3/28/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import PMSuperButton

final class AccountSettingsViewController: UIViewController {

    weak var delegate: AccountSettingsViewControllerDelegate?

    @IBOutlet weak var firstNameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var lastNameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var nickNameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var renWebIDTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var userNameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var userTypeButton: UIButton!
    @IBOutlet weak var updateButton: PMSuperButton!

    @IBOutlet weak var scrollView: UIScrollView!
    var activeTextField: UITextField?
    var regularContentInsets: UIEdgeInsets!

    let userTypeDict: [VerifyUserResult.UserType: String] = [.student: "Student", .staff: "Faculty/Staff", .family: "Family"]

    var userInfo: UserInfo
    init(userInfo: UserInfo) {
        self.userInfo = userInfo
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        firstNameTextField.text = userInfo.firstName
        lastNameTextField.text = userInfo.lastName
        nickNameTextField.text = userInfo.nickName
        emailTextField.text = userInfo.email
        renWebIDTextField.text = String(userInfo.renWebID)
        userNameTextField.text = userInfo.username

        setUserType(userInfo.userType)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)

        registerForKeyboardNotifications()
        regularContentInsets = scrollView.adjustedContentInset

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if scrollView.contentSize.height > view.safeAreaLayoutGuide.layoutFrame.height {
            scrollView.flashScrollIndicators()
        }
    }

    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown(_:)), name: .UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeHidden(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func setUserType(_ userType: VerifyUserResult.UserType) {

        if userType == .student {
            switch userInfo.studentType! {
            case .highSchool:
                userTypeButton.setTitle(userTypeDict[userType]! + " - HS ▼", for: .normal)
            case .middleSchool:
                userTypeButton.setTitle(userTypeDict[userType]! + " - MS ▼", for: .normal)
            }
        } else {
            userTypeButton.setTitle(userTypeDict[userType]! + " ▼", for: .normal)
        }
    }

    @objc func dismissKeyboard(_ sender: Any) {
        view.endEditing(true)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBAction func changeUserType(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: "I am a...", preferredStyle: .actionSheet)
        let userTypeDisplayDict: [String: VerifyUserResult.UserType] = ["Student - High School": .student,
                                                                        "Student - Middle School": .student,
                                                                        "Faculty/Staff": .staff,
                                                                        "Family": .family]
        for (key, value) in userTypeDisplayDict {
            actionSheet.addAction(UIAlertAction(title: key, style: .default, handler: { _ in
                self.userInfo.userType = value
                switch key {
                case "Student - High School":
                    self.userInfo.studentType = .highSchool
                case "Student - Middle School":
                    self.userInfo.studentType = .middleSchool
                default:
                    self.userInfo.studentType = nil
                }
                self.setUserType(value)
            }))
        }

        actionSheet.popoverPresentationController?.sourceView = userTypeButton
        actionSheet.popoverPresentationController?.sourceRect = userTypeButton.frame

        present(actionSheet, animated: true)
    }

    @IBAction func signOut(_ sender: Any) {
        delegate?.accountSettingsViewControllerDidSelectSignOut(self)
    }
    @IBAction func resetPassword(_ sender: Any) {
        delegate?.accountSettingsViewController(self, resetPasswordWith: userInfo.email)
    }
    @IBAction func updateUserInfo(_ sender: Any) {
        var invalidFields = 0
        for field in [firstNameTextField, lastNameTextField, emailTextField, userNameTextField, renWebIDTextField] {
            let isValid = validate(field!)
            configureTextField(field!, isValid: isValid)
            if !isValid { invalidFields += 1 }
        }
        if invalidFields == 0 {
            let userInfo = UserInfo(id: nil,
                                    username: userNameTextField.text!,
                                    firstName: firstNameTextField.text!,
                                    lastName: lastNameTextField.text!,
                                    nickName: nickNameTextField.text,
                                    userType: self.userInfo.userType,
                                    studentType: self.userInfo.studentType,
                                    email: emailTextField.text!,
                                    renWebID: self.userInfo.renWebID,
                                    isBetaTester: false)
            delegate?.accountSettingsViewController(self, update: userInfo)
        }
    }

    fileprivate func validate(_ textField: UITextField) -> Bool {
        if textField.text != nil {
            return true
        } else {
            return false
        }
    }
    fileprivate func configureTextField(_ textField: SkyFloatingLabelTextField, isValid: Bool) {
        if isValid {
            textField.lineColor = .black
        } else {
            textField.lineColor = .red
        }
    }
}

extension AccountSettingsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case firstNameTextField:
            lastNameTextField.becomeFirstResponder()
        case lastNameTextField:
            nickNameTextField.becomeFirstResponder()
        case nickNameTextField:
            emailTextField.becomeFirstResponder()
        case emailTextField:
            userNameTextField.becomeFirstResponder()
        default:
            view.endEditing(true)
        }

        return true
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeTextField = textField
        return true
    }
}

extension AccountSettingsViewController {
    @objc func keyboardWasShown(_ notification: Notification) {
        let kbSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        // If active text field is hidden by keyboard, scroll it so it's visible
        // Your app might not need or want this behavior.
        var aRect: CGRect = view.frame
        let obfuscated = kbSize.height
        aRect.size.height -= obfuscated
        var frameOrigin = activeTextField!.frame.origin
        frameOrigin.y += activeTextField!.frame.height
        if !aRect.contains(frameOrigin) {
            scrollView.scrollRectToVisible(activeTextField!.frame, animated: true)
        }
    }

    @objc func keyboardWillBeHidden(_ notification: Notification) {
        scrollView.contentInset = regularContentInsets
        scrollView.scrollIndicatorInsets = regularContentInsets
        scrollView.scrollToTop()
    }
}

protocol AccountSettingsViewControllerDelegate: class {
    func accountSettingsViewControllerDidSelectSignOut(_ viewController: AccountSettingsViewController)
    func accountSettingsViewController(_ viewController: AccountSettingsViewController, resetPasswordWith email: String)
    func accountSettingsViewController(_ viewController: AccountSettingsViewController, update userInfo: UserInfo)
}
