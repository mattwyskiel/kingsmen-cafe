//
//  Requestable.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 3/5/19.
//  Copyright © 2019 Christian Heritage School. All rights reserved.
//

import Foundation

protocol Requestable {
    var baseURL: URL { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var task: HTTPTask { get }
    var headers: HTTPHeaders? { get }
    var responseType: Codable.Type { get }
}
