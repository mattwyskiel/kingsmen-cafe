//
//  InAppPurchasingViewController.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 10/19/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import UIKit
import StoreKit

class InAppPurchasingViewController: UIViewController {

    @IBOutlet weak var productTypeLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productAfterIntroductoryPriceLabel: UILabel?
    @IBOutlet weak var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: Set labels
        let fullPriceString = product.price.currencyString(product.priceLocale)

        if isEligibleForIntroductoryPrice && product.introductoryPrice != nil {
            // is subscription (as opposed to one time purchase)
            // has introductory price
            let introPriceString = product.introductoryPrice!.price.currencyString(product.introductoryPrice!.priceLocale)
            productPriceLabel.text = introPriceString + " for the first year"

            productAfterIntroductoryPriceLabel?.text = fullPriceString + " per year after that"
        } else {
            if SubscriptionManager.shared.productIsSubscription(product) { // is subscription
                productPriceLabel.text = fullPriceString + " per year"
            } else { // one time
                productPriceLabel.text = fullPriceString + " - one-time purchase"
            }
            productAfterIntroductoryPriceLabel?.text = nil
        }
        print(product.localizedTitle)
        productTypeLabel.text = product.localizedTitle
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollView.flashScrollIndicators()
    }

    let product: SKProduct
    let isEligibleForIntroductoryPrice: Bool
    init(subscription: SKProduct, isEligibleForIntroductoryPrice: Bool) {
        self.product = subscription
        self.isEligibleForIntroductoryPrice = isEligibleForIntroductoryPrice
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    weak var delegate: PurchasingViewControllerDelegate?

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func showMoreInfo(_ sender: Any) {
        delegate?.purchasingViewControllerShowMoreInfo(self)
    }

    @IBAction func purchase(_ sender: Any) {
        delegate?.purchasingViewController(self, subscribeTo: product)
    }

    @IBAction func restorePurchase(_ sender: Any) {
        delegate?.purchasingViewControllerRestorePurchases(self)
    }

    @IBAction func showTerms(_ sender: Any) {
        let termsURL = URL(string: "https://img1.wsimg.com/blobby/go/6d554658-f6c0-4683-883c-2f111523cc4f/downloads/1covouo0e_209725.pdf")!
        delegate?.purchasingViewController(self, open: termsURL)
    }
    @IBAction func showPrivacyPolicy(_ sender: Any) {
        let privacyURL = URL(string: "https://img1.wsimg.com/blobby/go/6d554658-f6c0-4683-883c-2f111523cc4f/downloads/1covov0b0_650704.pdf")!
        delegate?.purchasingViewController(self, open: privacyURL)
    }

}

protocol PurchasingViewControllerDelegate: class {
    func purchasingViewController(_ viewController: InAppPurchasingViewController, subscribeTo product: SKProduct)
    func purchasingViewControllerRestorePurchases(_ viewController: InAppPurchasingViewController)
    func purchasingViewControllerShowMoreInfo(_ viewController: InAppPurchasingViewController)
    func purchasingViewController(_ viewController: InAppPurchasingViewController, open url: URL)
}
