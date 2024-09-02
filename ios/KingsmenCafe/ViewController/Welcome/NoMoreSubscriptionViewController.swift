//
//  NoMoreSubscriptionViewController.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 3/29/19.
//  Copyright © 2019 Christian Heritage School. All rights reserved.
//

import UIKit

class NoMoreSubscriptionViewController: UIViewController {

    weak var delegate: NoMoreSubscriptionViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func goToSettingsButtonPressed(_ sender: Any) {
        delegate?.goToSettings()
    }
}

protocol NoMoreSubscriptionViewControllerDelegate: class {
    func goToSettings()
}
