//
//  AppOpenURLRouter.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 4/16/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import Foundation

enum Route {
    case orderConfirmation
    case sendSupportEmail(subject: String, body: String)
}

extension Route {
    init?(url: URL) {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        switch components.host {
        case "order-confirmation":
            self = .orderConfirmation
        case "support-email":
            var query = [String: String]()
            for item in components.queryItems! {
                query[item.name] = item.value
            }
            self = .sendSupportEmail(subject: query["subject"]!, body: query["body"]!)
        default:
            return nil
        }
    }
}

final class AppOpenURLRouter {
    func handle(_ url: URL, _ coordinator: AppCoordinator) -> Bool {
        guard let route = Route(url: url) else { return false }
        switch route {
        case .orderConfirmation:
            coordinator.showOrderConfirmation()
            return true
        case .sendSupportEmail(let subject, let body):
            coordinator.sendSupportEmail(subject: subject, body: body)
            return true
        }
    }
}
