//
//  TransactionsListTableViewCell.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 7/12/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import UIKit

final class TransactionsListTableViewCell: UITableViewCell {

    @IBOutlet weak var orderSummaryLabel: UILabel!
    @IBOutlet weak var orderNumberLabel: UILabel!

    func configure(with item: OrderHistoryItem) {
        if item.checkout.order.lineItems.count == 1 {
            orderSummaryLabel.text = item.checkout.order.lineItems[0].name
        } else if item.checkout.order.lineItems.count > 1 {
            orderSummaryLabel.text = item.checkout.order.lineItems[0].name + " + " + String(item.checkout.order.lineItems.count - 1) + " more"
        }
        orderNumberLabel.text = "Order #: " + item.transaction.orderId
    }

}
