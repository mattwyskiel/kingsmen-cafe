//
//  AboutPourMikeysViewController.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 8/13/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import UIKit
import Anchorage

final class AboutPourMikeysViewController: UIViewController {

    @IBOutlet weak var contentView: AboutPourMikeysView!
    @IBOutlet weak var scrollView: UIScrollView!

    weak var delegate: AboutPourMikeysViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Pour Mikey's Coffee"

        contentView.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if contentView.frame.height > view.frame.height {
            scrollView.flashScrollIndicators()
        }
    }
}

extension AboutPourMikeysViewController: AboutPourMikeysViewDelegate {
    func aboutPourMikeysView(_ view: AboutPourMikeysView, open link: AboutPourMikeysView.Link) {
        delegate?.aboutPourMikeysViewController(self, open: link)
    }
}

protocol AboutPourMikeysViewControllerDelegate: class {
    func aboutPourMikeysViewController(_ viewController: AboutPourMikeysViewController, open link: AboutPourMikeysView.Link)
}
