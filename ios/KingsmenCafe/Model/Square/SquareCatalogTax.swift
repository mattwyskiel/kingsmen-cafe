//
//  SquareCatalogTax.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 4/1/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import Foundation

enum SquareCatalogRequestType: String {
    case taxes, items
}

struct SquareCatalogTax: Codable {
    let type: String = "TAX"
    let id: String
    let updatedAt: Date
    let version: Int
    let isDeleted: Bool

    struct CatalogV1Id: Codable {
        let catalogV1Id: String
        let locationId: String
        private enum CodingKeys: String, CodingKey {
            case catalogV1Id = "catalog_v1_id"
            case locationId = "location_id"
        }
    }
    let catalogV1Ids: [CatalogV1Id]

    let presentAtAllLocations: Bool
    let presentAtLocationIds: [String]

    struct TaxData: Codable {
        let name: String

        enum CalculationPhase: String, Codable {
            case subtotal = "TAX_SUBTOTAL_PHASE"
            case total = "TAX_TOTAL_PHASE"
        }
        let calculationPhase: CalculationPhase

        enum InclusionType: String, Codable {
            case additive = "ADDITIVE"
            case inclusive = "INCLUSIVE"
        }
        let inclusionType: String

        let percentage: String
        let appliesToCustomAmounts: Bool
        let enabled: Bool

        private enum CodingKeys: String, CodingKey {
            case name
            case calculationPhase = "calculation_phase"
            case inclusionType = "inclusion_type"
            case percentage
            case appliesToCustomAmounts = "applies_to_custom_amounts"
            case enabled
        }
    }
    let taxData: TaxData

    private enum CodingKeys: String, CodingKey {
        case type
        case id
        case updatedAt = "updated_at"
        case version
        case isDeleted = "is_deleted"
        case catalogV1Ids = "catalog_v1_ids"
        case presentAtAllLocations = "present_at_all_locations"
        case presentAtLocationIds = "present_at_location_ids"
        case taxData = "tax_data"
    }
}
