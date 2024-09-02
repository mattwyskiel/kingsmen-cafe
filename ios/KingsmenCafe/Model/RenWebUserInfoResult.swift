//
//  RenWebUserInfoResult.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 3/26/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import Foundation

struct RenWebUserInfoResult: Codable {
    var result: [Info]
    struct Info: Codable {
        var renWebID: Int?
        var renWebFamilyID: Int?
        var email: String
        var nickName: String?
        var lastName: String
        var firstName: String
        var renWebUserName: String?
        var grade: String?
    }
}
