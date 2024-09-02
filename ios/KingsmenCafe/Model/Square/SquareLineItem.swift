//
//  SquareLineItem.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 4/12/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import Foundation

public struct SquareLineItem: Codable {
    public let name: String
    public let quantity: String
    public struct BasePriceMoney: Codable {
        public let amount: Int
        public let currency: String = "USD"
    }
    public let basePriceMoney: BasePriceMoney
    private enum CodingKeys: String, CodingKey {
        case name
        case quantity
        case basePriceMoney = "base_price_money"
    }
}
