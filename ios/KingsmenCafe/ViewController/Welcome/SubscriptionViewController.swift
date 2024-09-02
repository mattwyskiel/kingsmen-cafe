//
//  SubscriptionViewController.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 8/27/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import UIKit
import StoreKit

// swiftlint:disable line_length
class SubscriptionViewController: InAppPurchasingViewController {

    @IBOutlet weak var legalLabel: UILabel!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // product is subscription
        let cost = product.price.currencyString(.current)
        let intro = product.introductoryPrice?.price.currencyString(.current)

        if product.introductoryPrice?.price == 0.00 {
            legalLabel.text = """
            A \(cost) subscription purchase will be applied to your iTunes account once the free year has been completed.
            Subscriptions will automatically renew (yearly for \(cost)) unless canceled within 24-hours before the end of the current period. You can cancel or check your payment status anytime with your iTunes account settings. Any unused portion of a free trial will be forfeited if you purchase a subscription.
            """
        } else {
            legalLabel.text = """
            A \(intro ?? cost) subscription purchase will be applied to your iTunes account upon confirmation.
            Subscriptions will automatically renew (yearly for \(cost)) unless canceled within 24-hours before the end of the current period. You can cancel anytime with your iTunes account settings. Any unused portion of a free trial will be forfeited if you purchase a subscription.
            """
        }
    }
}
// swiftlint:enable line_length
