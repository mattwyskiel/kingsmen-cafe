//
//  Int+Extensions.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 3/17/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import Foundation

extension Int {
    init?(_ string: String?) {
        guard let string = string else { return nil }
        self.init(string)
    }

    var squareAmountAsCurrencyFormattedString: String {
        let properDollarAmount = Float(self) / 100.0
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: properDollarAmount))!
    }
}

extension NSDecimalNumber {
    func currencyString(_ locale: Locale) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = locale.currencyCode
        return formatter.string(from: self)!
    }
}
