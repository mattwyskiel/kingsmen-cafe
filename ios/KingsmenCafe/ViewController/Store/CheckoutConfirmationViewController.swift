//
//  CheckoutConfirmationViewController.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 4/7/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import UIKit

final class CheckoutConfirmationViewController: UIViewController {

    weak var delegate: CheckoutConfirmationViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true
        title = "Order Confirmation"

        // Do any additional setup after loading the view.
    }
    @IBAction func donePressed(_ sender: Any) {
        delegate?.checkoutConfirmationViewControllerDidFinish(self)
    }
}

protocol CheckoutConfirmationViewControllerDelegate: class {
    func checkoutConfirmationViewControllerDidFinish(_ controller: CheckoutConfirmationViewController)
}
