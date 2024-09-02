//
//  NetworkErrorViewController.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 9/15/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import UIKit

class NetworkErrorViewController: UIViewController {

    weak var delegate: NetworkErrorViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func retry(_ sender: Any) {
        delegate?.networkErrorViewControllerDidSelectRetry(self)
    }
}

protocol NetworkErrorViewControllerDelegate: class {
    func networkErrorViewControllerDidSelectRetry(_ viewController: NetworkErrorViewController)
}
