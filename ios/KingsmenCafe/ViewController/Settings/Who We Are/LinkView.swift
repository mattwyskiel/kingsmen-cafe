//
//  LinkView.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 8/2/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import UIKit
import Static

final class LinkView: UITableViewCell, Cell {

    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var label: UILabel!

    func configure(row: Row) {
        let context = row.context!
        iconView.image = context["icon"] as? UIImage
        label.text = context["label"] as? String
    }

    static func nib() -> UINib? {
        return UINib(nibName: "LinkView", bundle: .main)
    }

}
