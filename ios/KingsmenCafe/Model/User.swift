//
//  User.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 3/12/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import Foundation

struct UserInfo: Codable {
    var id: String?
    var username: String
    var firstName: String
    var lastName: String
    var nickName: String?
    var userType: VerifyUserResult.UserType
    enum StudentType: String, Codable {
        case highSchool, middleSchool
    }
    var studentType: StudentType?
    var email: String
    var renWebID: Int
    var isBetaTester: Bool

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case username, firstName, lastName, nickName, email, renWebID, userType, studentType, isBetaTester
    }
}

final class User {
    typealias NetworkResult<T> = Result<T, NetworkError>
    class var isLoggedIn: Bool {
        return UserDefaults.standard.string(forKey: "auth_token") != nil
    }
    static var currentUser: User? {
        if isLoggedIn {
            return User()
        } else {
            return nil
        }
    }
    func getUserInfo(completionHandler: @escaping (NetworkResult<UserInfo>) -> Void) {
        NetworkProvider().request(.me, completionHandler)
    }
}
