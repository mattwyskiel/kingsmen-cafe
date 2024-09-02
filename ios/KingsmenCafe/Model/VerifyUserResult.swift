//
//  VerifyUserResult.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 3/10/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import Foundation

struct VerifyUserResult: Codable {
    enum UserType: String, Codable {
        case student
        case staff
        case family
    }
    var type: UserType

    struct Result: Codable {
        var renWebID: Int
    }
    var result: [Result]
}

enum VerifyUserKey: String {
    case email, userName
}
