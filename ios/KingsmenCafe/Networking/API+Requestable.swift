//
//  API+Requestable.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 3/5/19.
//  Copyright © 2019 Christian Heritage School. All rights reserved.
//

import Foundation

extension API: Requestable {
    var baseURL: URL {
        switch NetworkProvider.environment {
        case .dev:
            return URL(string: "http://localhost:3000/dev")!
        case .staging:
            return URL(string: "https://kingsmen-cafe-api-dev.herokuapp.com/v1.1")!
        case .production:
            return URL(string: "https://api.kingsmencafe.com/v1.1")!
        }
    }

    var path: String {
        switch self {
        case .upcomingEvents(let category, _, _):
            return "/calendar/upcoming/\(category.rawValue)"
        case .allEvents(let category):
            return "/calendar/all/\(category.rawValue)"

        case .news:
            return "/news"

        case .verifyAsPartOfCHS:
            return "/renweb/verify"
        case .findRenWebUserInfo(let type, let renWebID):
            return "/renweb/users/\(type.rawValue)/\(renWebID)"

        case .signUp:
            return "/users/signup"
        case .signIn:
            return "/users/signin"
        case .updateInfo:
            return "/users/update"
        case .me:
            return "/users/me"
        case .myQuickLinks:
            return "/users/me/quicklinks"

        case .forgotPassword:
            return "/users/forgot-password"

        case .storeCatalog(let type, _):
            return "/store/catalog/\(type.rawValue)"
        case .storeItem(let id):
            return "/store/catalog/items/\(id)"
        case .searchCatalog:
            return "/store/catalog/items/search"
        case .checkout:
            return "/store/checkout"
        case .getTransactions:
            return "/store/transactions"

        case .currentSubscriptionState:
            return "/users/me/current-ios-subscription-state"

        case .currentTerm:
            return "/schedule/current-term"
        case .getCurrentOrNextClass:
            return "/schedule/classes/now"
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .upcomingEvents,
             .allEvents,
             .news,
             .findRenWebUserInfo,
             .me, .myQuickLinks,
             .storeCatalog, .storeItem, .getTransactions,
             .currentTerm, .getCurrentOrNextClass:
            return .get
        case .verifyAsPartOfCHS, .signUp, .signIn, .updateInfo, .forgotPassword,
             .checkout, .searchCatalog, .currentSubscriptionState:
            return .post
        }
    }

    var sampleData: Data? {
        switch self {
        case .upcomingEvents(let category, _, _):
            return stubbedResponse("calendar-upcoming-" + category.rawValue)
        case .allEvents(let category):
            return stubbedResponse("calendar-all-" + category.rawValue)
        case .news:
            return stubbedResponse("news")
        case .verifyAsPartOfCHS:
            return stubbedResponse("renweb-verify")
        case .findRenWebUserInfo:
            return stubbedResponse("renweb-find-user-student") // refactor later for testing - all cases (currently just student)
        case .signUp(let userInfo, _), .updateInfo(let userInfo):
            return try! JSONEncoder().encode(userInfo)
        case .signIn:
            return stubbedResponse("users-sign-in")
        case .me:
            return stubbedResponse("users-me")
        case .myQuickLinks:
            return stubbedResponse("users-me-quicklinks")
        case .forgotPassword:
            return stubbedResponse("users-forgot-password")
        case .storeCatalog(let type, _):
            return stubbedResponse("store-catalog-\(type.rawValue)")
        case .searchCatalog:
            return stubbedResponse("store-catalog-search")
        case .storeItem:
            return stubbedResponse("store-catalog-items-individual")
        case .checkout:
            return stubbedResponse("store-checkout")
        case .getTransactions:
            return stubbedResponse("store-transactions")
        case .currentSubscriptionState:
            return """
            {
                "isBetaTester": false,
                "isSubscribed": false,
                "isInBusinessClass": false,
                "isEligibleForIntroductoryPricing": false
            }
            """.data(using: .utf8)!
        default:
            return nil
        }
    }

    var task: HTTPTask {
        switch self {
        case .upcomingEvents(_, let endDateKey, let endDateNumber):
            let parameters: Parameters = ["endDateKey": endDateKey, "endDateNumber": endDateNumber]
            return .requestWithParameters(.json(parameters))
        case .allEvents:
            return .plain

        case .news:
            return .plain

        case .verifyAsPartOfCHS(let key, let value):
            let parameters: Parameters = ["key": key.rawValue, "value": value]
            return .requestWithParameters(.json(parameters))
        case .findRenWebUserInfo:
            return .plain

        case .signUp(let userInfo, let password):
            var params = ["renWebID": userInfo.renWebID,
                          "email": userInfo.email,
                          "username": userInfo.username,
                          "lastName": userInfo.lastName,
                          "firstName": userInfo.firstName,
                          "password": password,
                          "userType": userInfo.userType.rawValue,
                          "isBetaTester": userInfo.isBetaTester] as [String: Any]
            if userInfo.nickName != nil {
                params["nickName"] = userInfo.nickName!
            }
            if userInfo.studentType != nil {
                params["studentType"] = userInfo.studentType!.rawValue
            }
            return .requestWithParameters(.json(params))
        case .signIn(let username, let password):
            let parameters: Parameters = ["username": username, "password": password]
            return .requestWithParameters(.json(parameters))
        case .updateInfo(let userInfo):
            let parameters = try! JSONSerialization.jsonObject(with: try! JSONEncoder().encode(userInfo)) as! Parameters
            return .requestWithParameters(.json(parameters))
        case .me, .myQuickLinks:
            return .plain
        case .forgotPassword(let email):
            let parameters: Parameters = ["email": email]
            return .requestWithParameters(.json(parameters))

        case .storeItem, .getTransactions:
            return .plain
        case let .storeCatalog(_, userType):
            if let userType = userType {
                let parameters: Parameters = ["userType": userType.rawValue]
                return .requestWithParameters(.url(parameters))
            } else {
                return .plain
            }
        case let .searchCatalog(order):
            let orderData = try! JSONEncoder().encode(order)
            return .requestWithData(orderData)
        case let .checkout(items, taxIDs):
            let itemParams = items.map { item in
                return SquareLineItem(name: item.name, quantity: String(item.quantity),
                                      basePriceMoney: SquareLineItem.BasePriceMoney(amount: item.unitPrice))
            }
            let taxIDParams = taxIDs.map { id in
                return SquareOrderRequestTax(name: id.taxData.name, percentage: id.taxData.percentage)
            }

            let itemData = try! JSONEncoder().encode(itemParams)
            let taxData = try! JSONEncoder().encode(taxIDParams)

            let itemJSON = try! JSONSerialization.jsonObject(with: itemData)
            let taxJSON = try! JSONSerialization.jsonObject(with: taxData)

            let params: Parameters = ["items": itemJSON, "taxes": taxJSON]

            return .requestWithParameters(.json(params))

        case let .currentSubscriptionState(receipt):
            if receipt != nil {
                let string = receipt!.base64EncodedString()
                return .requestWithParameters(.json(["receipt": string]))
            } else {
                return .plain
            }

        case let .currentTerm(currentDate):
            let formatter = ISO8601DateFormatter()
            formatter.timeZone = TimeZone(identifier: "EST")
            let isoDate = formatter.string(from: currentDate)

            return .requestWithParameters(.url(["date": isoDate]))
        case let .getCurrentOrNextClass(currentDate, term):
            let isoDate = ISO8601DateFormatter().string(from: currentDate)
            return .requestWithParameters(.url(["date": isoDate, "term": term.rawValue]))
        }
    }

    var headers: HTTPHeaders? {
        var info = ["Content-Type": "application/json"]
        switch self {
        case .me, .updateInfo, .checkout, .myQuickLinks, .currentSubscriptionState, .getTransactions, .getCurrentOrNextClass:
            if let jwtToken = UserDefaults.standard.string(forKey: "auth_token") {
                info["Authorization"] = jwtToken
            }
        default:
            break
        }
        return info
    }

    var responseType: Codable.Type {
        switch self {
        case .upcomingEvents:
            fatalError("not implemented")
        case .allEvents:
            fatalError("not implemented")
        case .news:
            fatalError("not implemented")
        case .verifyAsPartOfCHS:
            return VerifyUserResult.self
        case .findRenWebUserInfo:
            return RenWebUserInfoResult.self
        case .signUp:
            return UserInfo.self
        case .signIn:
            return AuthToken.self
        case .updateInfo:
            return UserInfo.self
        case .me:
            return UserInfo.self
        case .myQuickLinks:
            return [QuickLink].self
        case .forgotPassword:
            return BackendMessage.self
        case .storeCatalog(let type, _):
            switch type {
            case .taxes:
                return [SquareCatalogTax].self
            case .items:
                return [SquareCatalogItem].self
            }
        case .storeItem:
            return SquareCatalogItem.self
        case .searchCatalog:
            return [StoreCatalogSearchResult].self
        case .checkout:
            return CheckoutResponse.self
        case .getTransactions:
            return [OrderHistoryItem].self
        case .currentSubscriptionState:
            return SubscriptionManager.SubscriptionState.self
        case .currentTerm:
            return ScheduleTermResponse.self
        case .getCurrentOrNextClass:
            return ScheduleClassResponse.self
        }
    }
}

func stubbedResponse(_ filename: String) -> Data! {
    @objc final class TestClass: NSObject { }

    let bundle = Bundle(for: TestClass.self)
    let path = bundle.path(forResource: filename, ofType: "json")
    return (try? Data(contentsOf: URL(fileURLWithPath: path!)))
}
