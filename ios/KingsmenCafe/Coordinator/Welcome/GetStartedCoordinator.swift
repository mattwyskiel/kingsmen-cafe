//
//  GetStartedCoordinator.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 3/18/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import UIKit

final class GetStartedCoordinator: CoordinatorType {
    let identifier = "get-started"
    var subcoordinators: [CoordinatorType] = []

    weak var delegate: GetStartedCoordinatorDelegate?

    var rootViewController: UIViewController
    var navController: UINavigationController {
        return rootViewController as! UINavigationController
    }

    required init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }

    func start() {
        let verifyUserViewController = VerifyUserViewController()
        verifyUserViewController.delegate = self
        navController.show(verifyUserViewController, sender: self)
    }
}

extension GetStartedCoordinator: VerifyUserViewControllerDelegate {
    func verifyUserViewController(_ viewController: VerifyUserViewController, submitWithKey key: VerifyUserKey, value: String) {
        navController.present(LoadingIndicatorView(), animated: true)
        NetworkProvider().request(.verifyAsPartOfCHS(key: key, value: value)) { [navController] (result: NetworkProvider.Result<VerifyUserResult>) in
            guard case let .success(verification) = result else {
                if case let .failure(verifyError) = result {
                    self.handleFailure(with: verifyError, in: navController)
                    return
                } else {
                    fatalError() // enum is not working
                }
            }
            if verification.result.isEmpty {
                self.handleFailure(with: .otherError("No Results"), in: navController)
            } else {
                NetworkProvider().request(.findRenWebUserInfo(type: verification.type,
                                                              renWebID: verification.result[0].renWebID)
                ) { (result: NetworkProvider.Result<RenWebUserInfoResult>)  in
                    switch result {
                    case .success(let info):
                        DispatchQueue.main.async {
                            navController.dismiss(animated: true) {
                                self.presentViewController(userInfo: info, userType: verification.type)
                            }
                        }
                    case .failure(let error):
                        self.handleFailure(with: error, in: navController)
                        return
                    }
                }
            }
        }
    }

    func handleFailure(with error: NetworkError, in navController: UINavigationController) {
        DispatchQueue.main.async {
            navController.dismiss(animated: true)
            switch error {
            case .otherError(let other):
                if let string = other as? String, string == "No Results" {
                    NetworkProvider().handle(error, withVisualMessage: "User Not Found")
                } else {
                    NetworkProvider().handle(error)
                }

            default:
                NetworkProvider().handle(error)
            }

        }
    }

    func presentViewController(userInfo: RenWebUserInfoResult, userType: VerifyUserResult.UserType) {
        let signUpViewController = SignUpViewController(renWebUserInfo: userInfo, initialUserType: userType)
        signUpViewController.delegate = self
        navController.show(signUpViewController, sender: self)
    }
}

extension GetStartedCoordinator: SignUpViewControllerDelegate {
    func signUpViewController(_ viewController: SignUpViewController, signUpWithUser user: UserInfo, password: String) {
        NetworkProvider().requestAndHandleError(.signUp(userInfo: user, password: password),
                                                in: viewController,
                                                errorVisualMessage: "There has been an error signing up. Please try again.") { (result: UserInfo) in
            NetworkProvider().requestAndHandleError(.signIn(username: result.username, password: password),
                                                    in: viewController,
                                                    // swiftlint:disable line_length
                                                    errorVisualMessage: "There has been an error signing in to your new account. Please try signing up again.") { [unowned self] (token: AuthToken) in
                                                        // swiftlint:enable line_length
                UserDefaults.standard.setValue(token.token, forKey: "auth_token")
                viewController.dismissInMainQueue {
                    self.delegate?.getStartedCoordinatorDidFinish(self)
                }

            }
        }
    }
}

protocol GetStartedCoordinatorDelegate: class {
    func getStartedCoordinatorDidFinish(_ coordinator: GetStartedCoordinator)
}
