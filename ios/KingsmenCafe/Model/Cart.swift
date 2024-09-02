//
//  Cart.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 4/3/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import Foundation

final class Cart {

    static let shared = Cart()
    private init() { }

    var tax: SquareCatalogTax?
    var items: [CartItem] = [] {
        didSet {
            didChange()
        }
    }

    func didChange() {
        NotificationCenter.default.post(name: .cartDidChange, object: nil)
    }

    // for display
    var subtotal: Int { // in cents
        var subtotal = 0
        for item in items {
            subtotal += item.fullPrice
        }
        return subtotal
    }
    var taxAmount: Int { // in cents
        if let tax = tax {
            let percentage = Double(tax.taxData.percentage)! / 100
            let doubleSub = Double(subtotal)
            return Int(doubleSub * percentage)
        } else {
            return 0
        }
    }
    var total: Int { // in cents
        return subtotal + taxAmount
    }

    func clear() {
        items = []
    }
}

extension Notification.Name {
    static var cartDidChange: Notification.Name {
        return Notification.Name("org.kingsmen.kingsmen-cafe.CartDidChange")
    }
}
