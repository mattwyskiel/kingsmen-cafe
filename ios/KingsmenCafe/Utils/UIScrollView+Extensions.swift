//
//  UIScrollView+Extensions.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 8/16/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import UIKit

extension UIScrollView {
    func scrollToTop() {
        let desiredOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(desiredOffset, animated: true)
    }
}
