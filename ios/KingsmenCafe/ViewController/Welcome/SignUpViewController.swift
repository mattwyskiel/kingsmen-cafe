//
//  SignUpViewController.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 3/17/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import AlertBar

final class SignUpViewController: UIViewController {

    weak var delegate: SignUpViewControllerDelegate?
    var renWebUserInfo: RenWebUserInfoResult.Info
    var userType: VerifyUserResult.UserType
    var studentType: UserInfo.StudentType?

    init(renWebUserInfo: RenWebUserInfoResult, initialUserType: VerifyUserResult.UserType) {
        self.renWebUserInfo = renWebUserInfo.result[0]
        userType = initialUserType
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let userTypeDict: [VerifyUserResult.UserType: String] = [.student: "Student", .staff: "Faculty/Staff", .family: "Family"]

    var regularContentInsets: UIEdgeInsets!

    override func viewDidLoad() {
        firstNameTextField.text = renWebUserInfo.firstName
        lastNameTextField.text = renWebUserInfo.lastName
        nickNameTextField.text = renWebUserInfo.nickName

        setUserType(userType)
        emailTextField.text = renWebUserInfo.email

        if let renWebID = renWebUserInfo.renWebID {
            renWebIDTextField.text = String(renWebID)
        } else if let renWebFamilyID = renWebUserInfo.renWebFamilyID {
            renWebIDTextField.text = String(renWebFamilyID)
        }

        usernameTextField.text = renWebUserInfo.renWebUserName

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)

        registerForKeyboardNotifications()
        regularContentInsets = scrollView.adjustedContentInset
    }

    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown(_:)), name: .UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeHidden(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func setUserType(_ userType: VerifyUserResult.UserType) {
        if userType == .student && renWebUserInfo.grade != nil {
            let highSchool = ["09", "10", "11", "12"]
            let middleSchool = ["06", "07", "08"]

            if highSchool.contains(renWebUserInfo.grade!) {
                studentType = .highSchool
                userTypeButton.setTitle(userTypeDict[userType]! + " - HS ▼", for: .normal)
            } else if middleSchool.contains(renWebUserInfo.grade!) {
                studentType = .middleSchool
                userTypeButton.setTitle(userTypeDict[userType]! + " - MS ▼", for: .normal)
            }
        } else {
            studentType = nil
            userTypeButton.setTitle(userTypeDict[userType]! + " ▼", for: .normal)
        }
    }

    @objc func dismissKeyboard(_ sender: Any) {
        view.endEditing(true)
    }

    @IBOutlet weak var firstNameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var lastNameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var nickNameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var userTypeButton: UIButton!
    @IBOutlet weak var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var renWebIDTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var usernameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var verifyPasswordTextField: SkyFloatingLabelTextField!

    var activeTextField: UITextField?

    @IBOutlet weak var scrollView: UIScrollView!

    @IBAction func changeUserType(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: "I am a...", preferredStyle: .actionSheet)
        let userTypeDisplayDict: [String: VerifyUserResult.UserType] = ["Student - High School": .student,
                                                                        "Student - Middle School": .student,
                                                                        "Faculty/Staff": .staff,
                                                                        "Family": .family]
        for (key, value) in userTypeDisplayDict {
            actionSheet.addAction(UIAlertAction(title: key, style: .default, handler: { _ in
                self.userType = value
                switch key {
                case "Student - High School":
                    self.renWebUserInfo.grade = "09"
                case "Student - Middle School":
                    self.renWebUserInfo.grade = "06"
                default:
                    self.renWebUserInfo.grade = nil
                }
                self.setUserType(value)
            }))
        }

        actionSheet.popoverPresentationController?.sourceView = userTypeButton
        actionSheet.popoverPresentationController?.sourceRect = userTypeButton.frame

        present(actionSheet, animated: true)
    }

    @IBAction func submit(_ sender: Any) {
        guard verifyPasswordTextField.text == passwordTextField.text else {
            configureTextField(verifyPasswordTextField, isValid: false)
            configureTextField(passwordTextField, isValid: false)
            AlertBar.shared.show(type: .error, message: "Password Fields do not match.")
            return
        }
        var invalidFields = 0
        for field in [firstNameTextField, lastNameTextField, emailTextField, usernameTextField, passwordTextField, renWebIDTextField] {
            let isValid = validate(field!)
            configureTextField(field!, isValid: isValid)
            if !isValid { invalidFields += 1 }
        }
        if invalidFields == 0 {
            let renWebID: Int
            if let renWebStudentID = renWebUserInfo.renWebID {
                renWebID = renWebStudentID
            } else if let renWebFamilyID = renWebUserInfo.renWebFamilyID {
                renWebID = renWebFamilyID
            } else {
                fatalError("No RenWeb ID")
            }

            let studentType = userType == .student ? self.studentType : nil

            let userInfo = UserInfo(id: nil,
                                    username: usernameTextField.text!,
                                    firstName: firstNameTextField.text!,
                                    lastName: lastNameTextField.text!,
                                    nickName: nickNameTextField.text,
                                    userType: userType,
                                    studentType: studentType,
                                    email: emailTextField.text!,
                                    renWebID: renWebID,
                                    isBetaTester: false)
            delegate?.signUpViewController(self, signUpWithUser: userInfo, password: passwordTextField.text!)
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

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case firstNameTextField:
            lastNameTextField.becomeFirstResponder()
        case lastNameTextField:
            nickNameTextField.becomeFirstResponder()
        case nickNameTextField:
            emailTextField.becomeFirstResponder()
        case emailTextField:
            usernameTextField.becomeFirstResponder()
        case usernameTextField:
            passwordTextField.becomeFirstResponder()
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

extension SignUpViewController {
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
        let frameOrigin = activeTextField!.frame.origin
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

protocol SignUpViewControllerDelegate: class {
    func signUpViewController(_ viewController: SignUpViewController, signUpWithUser user: UserInfo, password: String)
}
