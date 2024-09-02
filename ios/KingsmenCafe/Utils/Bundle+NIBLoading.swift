//
//  Bundle+NIBLoading.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 8/13/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import UIKit

extension Bundle {

    static func loadView<T>(fromNib name: String, withType type: T.Type) -> T {
        if let view = Bundle.main.loadNibNamed(name, owner: nil, options: nil)?.first as? T {
            return view
        }

        fatalError("Could not load view")
    }
}
