//
//  SubscriptionPurchaseData.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 9/3/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import Foundation

struct SubscriptionPurchaseData: Codable {
    let bundleId: String
    let appItemId: String
    let originalTransactionId: String
    let transactionId: String
    let productId: String
    let originalPurchaseDate: Date
    let purchaseDate: Date
    let quantity: Int
    let expirationDate: Date
    let isTrial: Bool
    let cancellationDate: Date
}
