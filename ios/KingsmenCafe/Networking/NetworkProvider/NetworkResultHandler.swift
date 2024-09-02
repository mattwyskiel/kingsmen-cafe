//
//  NetworkResultHandler.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 5/28/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//
// swiftlint:disable cyclomatic_complexity

import UIKit
import AlertBar

extension NetworkProvider {
    func requestAndHandleError<T: Codable>(_ target: API,
                                           in viewController: UIViewController? = nil,
                                           errorVisualMessage: String? = nil,
                                           _ successHandler: @escaping (T) -> Void) {
        if viewController != nil { viewController?.present(LoadingIndicatorView(), animated: true)}
        func handle(_ result: Result<T>) {
            switch result {
            case .success(let item):
                successHandler(item)
            case .failure(let error):
                self.handle(error, withVisualMessage: errorVisualMessage)
            }
        }
        request(target) { (result: Result<T>) in
            if viewController != nil {
                DispatchQueue.main.async {
                    viewController?.dismiss(animated: true) {
                        handle(result)
                    }
                }
            } else {
                handle(result)
            }
        }
    }

    func handle(_ error: NetworkError, withVisualMessage visualMessage: String? = nil) {
        print(error)
        switch error {
        case .urlSessionError(let urlserror):
            print(urlserror)
            if let message = visualMessage {
                AlertBar.shared.show(type: .error, message: message)
            } else {
                AlertBar.shared.show(type: .error, message: "There was an error. Please try again")
            }
        case .encodingError(let encodingError):
            print(encodingError)
            if let message = visualMessage {
                AlertBar.shared.show(type: .error, message: message)
            } else {
                AlertBar.shared.show(type: .error, message: "There was an error. Please try again")
            }
        case .badRequest(let message):
            if let mess = visualMessage {
                AlertBar.shared.show(type: .error, message: mess)
            } else {
                AlertBar.shared.show(type: .error, message: message.displayMessage)
            }
        case .decodingError(let decodingErr):
            print(decodingErr)
            //print(response)
            if let message = visualMessage {
                AlertBar.shared.show(type: .error, message: message)
            } else {
                AlertBar.shared.show(type: .error, message: "There was an error. Please try again")
            }
        case .serverError(let message):
            print(message)
            if let mess = visualMessage {
                AlertBar.shared.show(type: .error, message: mess)
            } else {
                AlertBar.shared.show(type: .error, message: message.displayMessage)
            }
        case .unrecognizedServerResponse(let response):
            print(response)
            if let mess = visualMessage {
                AlertBar.shared.show(type: .error, message: mess)
            } else {
                AlertBar.shared.show(type: .error, message: "There was an error. Please try again")
            }
        case .noData(let response):
            print(response)
            if let message = visualMessage {
                AlertBar.shared.show(type: .error, message: message)
            } else {
                AlertBar.shared.show(type: .error, message: "There was an error. Please try again")
            }
        case .noResponse:
            if let message = visualMessage {
                AlertBar.shared.show(type: .error, message: message)
            } else {
                AlertBar.shared.show(type: .error, message: "There was an error. Please try again")
            }
        case .otherError(let other):
            print(other)
            //print(response ?? "")
            if let message = visualMessage {
                AlertBar.shared.show(type: .error, message: message)
            } else {
                AlertBar.shared.show(type: .error, message: "There was an error. Please try again")
            }
        case .authenticationError:
            AlertBar.shared.show(type: .error, message: "There has been an authentication error. Please sign out of the app and then sign in again.")
        }
    }

    private func messageFromBackendErrorObject(data: Data) -> String? {
        if let backendMessage = try? JSONDecoder().decode(BackendMessage.self, from: data) {
            print(backendMessage)
            return backendMessage.displayMessage
        } else {
            return nil
        }
    }

}
