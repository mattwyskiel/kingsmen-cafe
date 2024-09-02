//
//  BackendError.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 3/19/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import Foundation
import GenericJSON

struct BackendMessage: Codable {
    var success: Bool
    var message: String
    var displayMessage: String
    var otherInfo: JSON?
}
