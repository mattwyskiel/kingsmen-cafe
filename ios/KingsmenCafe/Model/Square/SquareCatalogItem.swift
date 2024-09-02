//
//  SquareCatalogItem.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 3/31/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import Foundation
public struct SquareCatalogItem: Codable {
    public let type: String
    public let id: String
    public let updatedAt: Date
    public let version: Int
    public let isDeleted: Bool
    public let presentAtAllLocations: Bool
    public struct ItemData: Codable {
        public let name: String
        public let description: String?
        public let labelColor: String?
        public let availableOnline: Bool?
        public let availableForPickup: Bool?
        public let availableElectronically: Bool?
        public struct Variation: Codable {
            public let type: String
            public let id: String
            public let updatedAt: Date
            public let version: Int
            public let isDeleted: Bool
            public let presentAtAllLocations: Bool
            public struct ItemVariationData: Codable {
                public let itemId: String
                public let name: String
                public let ordinal: Int
                public let pricingType: String
                public let sku: String?
                public struct PriceMoney: Codable {
                    public let amount: Int
                    public let currency: String
                }
                public let priceMoney: PriceMoney?
                public let serviceDuration: Int?
                public struct LocationOverride: Codable {
                    public let locationId: String
                    public let trackInventory: Bool
                    private enum CodingKeys: String, CodingKey {
                        case locationId = "location_id"
                        case trackInventory = "track_inventory"
                    }
                }
                public let locationOverrides: [LocationOverride]?
                private enum CodingKeys: String, CodingKey {
                    case itemId = "item_id"
                    case name
                    case ordinal
                    case pricingType = "pricing_type"
                    case sku
                    case priceMoney = "price_money"
                    case serviceDuration = "service_duration"
                    case locationOverrides = "location_overrides"
                }
            }
            public let itemVariationData: ItemVariationData
            public struct CatalogV1Id: Codable {
                public let catalogV1Id: String
                public let locationId: String
                private enum CodingKeys: String, CodingKey {
                    case catalogV1Id = "catalog_v1_id"
                    case locationId = "location_id"
                }
            }
            public let catalogV1Ids: [CatalogV1Id]?
            public let presentAtLocationIds: [String]?
            private enum CodingKeys: String, CodingKey {
                case type
                case id
                case updatedAt = "updated_at"
                case version
                case isDeleted = "is_deleted"
                case presentAtAllLocations = "present_at_all_locations"
                case itemVariationData = "item_variation_data"
                case catalogV1Ids = "catalog_v1_ids"
                case presentAtLocationIds = "present_at_location_ids"
            }
        }
        public let variations: [Variation]
        public let productType: String
        public let skipModifierScreen: Bool
        public let categoryId: String?
        public let taxIds: [String]?
        public let imageUrl: URL?
        private enum CodingKeys: String, CodingKey {
            case name
            case description
            case labelColor = "label_color"
            case availableOnline = "available_online"
            case availableForPickup = "available_for_pickup"
            case availableElectronically = "available_electronically"
            case variations
            case productType = "product_type"
            case skipModifierScreen = "skip_modifier_screen"
            case categoryId = "category_id"
            case taxIds = "tax_ids"
            case imageUrl = "image_url"
        }
    }
    public let itemData: ItemData
    private enum CodingKeys: String, CodingKey {
        case type
        case id
        case updatedAt = "updated_at"
        case version
        case isDeleted = "is_deleted"
        case presentAtAllLocations = "present_at_all_locations"
        case itemData = "item_data"
    }
}
