//
//  SubscriptionManager.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 8/25/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import Foundation
import StoreKit

enum SubscriptionError: Error {
    case noReceipt
}

extension Notification.Name {
    static let storeTransactionMade = Notification.Name(rawValue: "com.kingsmencafe.kingsmencafe.storeTransactionMade")
}

class SubscriptionManager: NSObject {

    static let shared = SubscriptionManager()
    private override init() {

    }

    func initialize() {
        SKPaymentQueue.default().add(self)
    }

    func productIdentifier(for userType: VerifyUserResult.UserType, isBetaTester: Bool, isInBusinessClass: Bool) -> String {
        if userType == .staff {
            if isBetaTester {
                return "com.kingsmencafe.subscription.teacher.beta"
            } else {
                return "com.kingsmencafe.subscription.teacher"
            }
        } else {
            if isBetaTester {
                if isInBusinessClass {
                    return "com.kingsmencafe.subscription.beta.inclass"
                } else {
                    return "com.kingsmencafe.subscription.beta"
                }
            } else {
                return "com.kingsmencafe.subscription.standard"
            }
        }
    }

    func productIsSubscription(_ product: SKProduct) -> Bool {
        switch product.productIdentifier {
        case "com.kingsmencafe.subscription.standard":
            return true
        case "com.kingsmencafe.subscription.beta":
            return true
        case "com.kingsmencafe.subscription.beta.inclass":
            return true
        default:
            return false
        }
    }

    var fetchProductCompletion: ((SKProduct) -> Void)! = nil
    func fetchProduct(for id: String, completion: @escaping (SKProduct) -> Void) {
        fetchProductCompletion = completion

        let productsRequest = SKProductsRequest(productIdentifiers: [id])
        productsRequest.delegate = self
        productsRequest.start()
    }

    func purchase(_ product: SKProduct) {
        let payment = SKMutablePayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    var refreshReceiptCompletion: ((_ success: Bool) -> Void)! = nil
    func refreshReceipt(completion: @escaping (Bool) -> Void) {

        refreshReceiptCompletion = completion

        let request = SKReceiptRefreshRequest()
        request.delegate = self
        request.start()
    }
    /**
    func findSubscriptions(completion: @escaping (NetworkProvider.NetworkResult<[SubscriptionPurchaseData]>) -> ()) {
        guard let receipt = loadReceipt() else {
            completion(.failure(MoyaError.underlying(SubscriptionError.noReceipt, nil)))
            return
        }
        NetworkProvider().request(.currentSubscriptions(receipt: receipt), completion)
    }**/

    struct SubscriptionState: Codable {
        var isBetaTester: Bool = false
        var isSubscribed: Bool = false
        var isInBusinessClass: Bool = false
        var isEligibleForIntroductoryPricing = false
        var userType: VerifyUserResult.UserType
        var isAfterSubscription = true
    }

    func getSubscriptionState(usingReceipt: Bool = false, completion: @escaping (NetworkProvider.Result<SubscriptionState>) -> Void) {
        let receipt = usingReceipt ? self.loadReceipt() : nil
        NetworkProvider().request(.currentSubscriptionState(receipt: receipt), completion)
    }

    private func loadReceipt() -> Data? {
        guard let url = Bundle.main.appStoreReceiptURL else {
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            return data
        } catch {
            print("Error loading receipt data: \(error.localizedDescription)")
            return nil
        }
    }

}

extension SubscriptionManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        fetchProductCompletion(response.products[0])
        fetchProductCompletion = nil
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        if request is SKReceiptRefreshRequest {
            refreshReceiptCompletion(false)
            refreshReceiptCompletion = nil
        }
    }

    func requestDidFinish(_ request: SKRequest) {
        if request is SKReceiptRefreshRequest {
            refreshReceiptCompletion(true)
            refreshReceiptCompletion = nil
        }
    }
}

struct PaymentQueueAndTransaction {
    let transaction: SKPaymentTransaction
    let queue: SKPaymentQueue
}

extension SubscriptionManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            let queueAndTransaction = PaymentQueueAndTransaction(transaction: transaction, queue: queue)
            NotificationCenter.default.post(name: .storeTransactionMade, object: queueAndTransaction)
        }
    }
}
