//
//  OrderHistoryItem.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 7/12/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import Foundation

public struct OrderHistoryItem: Codable {
    public struct Transaction: Codable {
        public struct Tender: Codable {
            public let type: String
            public let id: String
            public let locationId: String
            public let transactionId: String
            public let createdAt: Date
            public let note: String
            public struct AmountMoney: Codable {
                public let amount: Int
                public let currency: String
            }
            public let amountMoney: AmountMoney
            public struct ProcessingFeeMoney: Codable {
                public let amount: Int
                public let currency: String
            }
            public let processingFeeMoney: ProcessingFeeMoney
            public let customerId: String
            public struct CardDetails: Codable {
                public let status: String
                public struct Card: Codable {
                    public let cardBrand: String
                    public let last4: Int
                    public let fingerprint: String
                    private enum CodingKeys: String, CodingKey {
                        case cardBrand = "card_brand"
                        case last4 = "last_4"
                        case fingerprint
                    }
                }
                public let card: Card
                public let entryMethod: String
                private enum CodingKeys: String, CodingKey {
                    case status
                    case card
                    case entryMethod = "entry_method"
                }
            }
            public let cardDetails: CardDetails
            private enum CodingKeys: String, CodingKey {
                case type
                case id
                case locationId = "location_id"
                case transactionId = "transaction_id"
                case createdAt = "created_at"
                case note
                case amountMoney = "amount_money"
                case processingFeeMoney = "processing_fee_money"
                case customerId = "customer_id"
                case cardDetails = "card_details"
            }
        }
        public let tenders: [Tender]
        public let id: String
        public let locationId: String
        public let createdAt: Date
        public let referenceId: String
        public let product: String
        public let orderId: String
        public let transactionId: String
        public let checkoutId: String
        public let v: Int
        private enum CodingKeys: String, CodingKey {
            case tenders
            case id = "_id"
            case locationId = "location_id"
            case createdAt = "created_at"
            case referenceId = "reference_id"
            case product
            case orderId = "order_id"
            case transactionId = "transaction_id"
            case checkoutId = "checkout_id"
            case v = "__v"
        }
    }
    public let transaction: Transaction
    public struct Checkout: Codable {
        public let id: String
        public let checkoutPageUrl: URL
        public let askForShippingAddress: Bool
        public let prePopulateBuyerEmail: String
        public let redirectUrl: URL
        public struct Order: Codable {
            public struct LineItem: Codable {
                public struct Taxe: Codable {
                    public let name: String
                    public let type: String
                    public let percentage: String
                    public struct AppliedMoney: Codable {
                        public let amount: Int
                        public let currency: String
                    }
                    public let appliedMoney: AppliedMoney
                    private enum CodingKeys: String, CodingKey {
                        case name
                        case type
                        case percentage
                        case appliedMoney = "applied_money"
                    }
                }
                public let taxes: [Taxe]
                public let name: String
                public let quantity: Int
                public struct BasePriceMoney: Codable {
                    public let amount: Int
                    public let currency: String
                }
                public let basePriceMoney: BasePriceMoney
                public struct GrossSalesMoney: Codable {
                    public let amount: Int
                    public let currency: String
                }
                public let grossSalesMoney: GrossSalesMoney
                public struct TotalTaxMoney: Codable {
                    public let amount: Int
                    public let currency: String
                }
                public let totalTaxMoney: TotalTaxMoney
                public struct TotalDiscountMoney: Codable {
                    public let amount: Int
                    public let currency: String
                }
                public let totalDiscountMoney: TotalDiscountMoney
                public struct TotalMoney: Codable {
                    public let amount: Int
                    public let currency: String
                }
                public let totalMoney: TotalMoney
                private enum CodingKeys: String, CodingKey {
                    case taxes
                    case name
                    case quantity
                    case basePriceMoney = "base_price_money"
                    case grossSalesMoney = "gross_sales_money"
                    case totalTaxMoney = "total_tax_money"
                    case totalDiscountMoney = "total_discount_money"
                    case totalMoney = "total_money"
                }
            }
            public let lineItems: [LineItem]
            public let locationId: String
            public let referenceId: String
            public struct TotalMoney: Codable {
                public let amount: Int
                public let currency: String
            }
            public let totalMoney: TotalMoney
            public struct TotalTaxMoney: Codable {
                public let amount: Int
                public let currency: String
            }
            public let totalTaxMoney: TotalTaxMoney
            public struct TotalDiscountMoney: Codable {
                public let amount: Int
                public let currency: String
            }
            public let totalDiscountMoney: TotalDiscountMoney
            private enum CodingKeys: String, CodingKey {
                case lineItems = "line_items"
                case locationId = "location_id"
                case referenceId = "reference_id"
                case totalMoney = "total_money"
                case totalTaxMoney = "total_tax_money"
                case totalDiscountMoney = "total_discount_money"
            }
        }
        public let order: Order
        public let createdAt: Date
        public let checkoutId: String
        public let v: Int
        private enum CodingKeys: String, CodingKey {
            case id = "_id"
            case checkoutPageUrl = "checkout_page_url"
            case askForShippingAddress = "ask_for_shipping_address"
            case prePopulateBuyerEmail = "pre_populate_buyer_email"
            case redirectUrl = "redirect_url"
            case order
            case createdAt = "created_at"
            case checkoutId = "checkout_id"
            case v = "__v"
        }
    }
    public let checkout: Checkout
}
