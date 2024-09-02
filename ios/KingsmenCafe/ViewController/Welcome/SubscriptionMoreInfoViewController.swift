//
//  SubscriptionMoreInfoViewController.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 9/5/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import UIKit

class SubscriptionMoreInfoViewController: UIViewController {

    weak var delegate: SubscriptionMoreInfoViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        let closeItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close(_:)))
        navigationItem.leftBarButtonItem = closeItem

        // Do any additional setup after loading the view.
    }

    @objc func close(_ sender: Any) {
        delegate?.subscriptionMoreInfoViewControllerDidFinish(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func showTerms(_ sender: Any) {
        let termsURL = URL(string: "https://img1.wsimg.com/blobby/go/6d554658-f6c0-4683-883c-2f111523cc4f/downloads/1covouo0e_209725.pdf")!
        delegate?.subscriptionMoreInfoViewController(self, open: termsURL)
    }

    @IBAction func showPrivacyPolicy(_ sender: Any) {
        let privacyURL = URL(string: "https://img1.wsimg.com/blobby/go/6d554658-f6c0-4683-883c-2f111523cc4f/downloads/1covov0b0_650704.pdf")!
        delegate?.subscriptionMoreInfoViewController(self, open: privacyURL)
    }
}

protocol SubscriptionMoreInfoViewControllerDelegate: class {
    func subscriptionMoreInfoViewController(_ viewController: SubscriptionMoreInfoViewController,
                                            open url: URL)
    func subscriptionMoreInfoViewControllerDidFinish(_ viewController: SubscriptionMoreInfoViewController)
}
