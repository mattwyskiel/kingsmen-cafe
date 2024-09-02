//
//  UIViewController+Extensions.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 9/3/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import UIKit

extension UIViewController {
    func dismissInMainQueue(completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: completion)
        }
    }
}
