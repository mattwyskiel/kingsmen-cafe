//
//  StoreProductTypeCell.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 3/28/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import UIKit

final class StoreProductTypeCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var highightView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 1.0
        self.layer.masksToBounds = false
    }
}
