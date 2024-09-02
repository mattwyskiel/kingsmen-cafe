//
//  StoreCatalogSearchResult.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 7/26/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import Foundation

public struct StoreCatalogSearchResult: Codable {
    public let itemId: String
    public let name: String
    public let sku: String
    public let ordinal: Int
    public let pricingType: String
    public struct PriceMoney: Codable {
        public let amount: Int
        public let currency: String
    }
    public let priceMoney: PriceMoney
    public struct LocationOverride: Codable {
        public let locationId: String
        public let trackInventory: Bool
        private enum CodingKeys: String, CodingKey {
            case locationId = "location_id"
            case trackInventory = "track_inventory"
        }
    }
    public let locationOverrides: [LocationOverride]?
    public let imageUrl: URL
    private enum CodingKeys: String, CodingKey {
        case itemId = "item_id"
        case name
        case sku
        case ordinal
        case pricingType = "pricing_type"
        case priceMoney = "price_money"
        case locationOverrides = "location_overrides"
        case imageUrl = "image_url"
    }
}
