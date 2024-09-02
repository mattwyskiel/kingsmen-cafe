//
//  JSON+Extensions.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 3/19/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import Foundation
import GenericJSON

extension JSON {
    subscript(key: String) -> Any? {
        switch self {
        case .object(let object):
            return object[key]
        default:
            return nil
        }
    }
}
