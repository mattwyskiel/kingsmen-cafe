//
//  CartItem.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 4/3/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import Foundation

final class CartItem {
    var name: String
    var unitPrice: Int
    var imageURL: URL?
    var quantity: Int {
        didSet {
            Cart.shared.didChange()
        }
    }

    init(squareProductInfo: SquareCatalogItem.ItemData.Variation, imageURL: URL?, quantity: Int = 1) {
        self.name = squareProductInfo.itemVariationData.name
        self.unitPrice = squareProductInfo.itemVariationData.priceMoney!.amount
        self.imageURL = imageURL
        self.quantity = quantity
    }

    init(searchResult: StoreCatalogSearchResult, quantity: Int = 1) {
        self.name = searchResult.name
        self.unitPrice = searchResult.priceMoney.amount
        self.imageURL = searchResult.imageUrl
        self.quantity = quantity
    }
}

extension CartItem {
    var fullPrice: Int {
        return unitPrice * quantity
    }
}
