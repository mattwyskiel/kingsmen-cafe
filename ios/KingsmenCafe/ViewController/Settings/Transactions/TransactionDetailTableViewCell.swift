//
//  TransactionDetailTableViewCell.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 7/12/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import UIKit

final class TransactionDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!

    func configure(with item: OrderHistoryItem.Checkout.Order.LineItem) {
        itemNameLabel.text = item.name
        priceLabel.text = item.basePriceMoney.amount.squareAmountAsCurrencyFormattedString
        quantityLabel.text = String(item.quantity)
    }
}
