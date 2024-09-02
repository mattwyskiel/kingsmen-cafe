//
//  API.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 2/15/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import Foundation

enum API {
    case upcomingEvents(category: EventCategory, endDateKey: String, endDateNumber: Int)
    case allEvents(category: EventCategory)

    case news

    case verifyAsPartOfCHS(key: VerifyUserKey, value: String)
    case findRenWebUserInfo(type: VerifyUserResult.UserType, renWebID: Int)

    case signUp(userInfo: UserInfo, password: String)
    case signIn(username: String, password: String) // Authenticated
    case updateInfo(userInfo: UserInfo) // Authenticated
    case me // Authenticated
    case myQuickLinks // Authenticated

    case forgotPassword(email: String) // Authenticated

    case storeCatalog(type: SquareCatalogRequestType, userType: VerifyUserResult.UserType?)
    case storeItem(id: String)
    case searchCatalog(fromOrder: OrderHistoryItem.Checkout.Order)
    case checkout(items: [CartItem], taxIDs: [SquareCatalogTax]) // Authenticated
    case getTransactions // Authenticated

    case currentSubscriptionState(receipt: Data?) // Authenticated

    case currentTerm(currentDate: Date)
    case getCurrentOrNextClass(currentDate: Date, term: ScheduleTerm) // Authenticated
}
