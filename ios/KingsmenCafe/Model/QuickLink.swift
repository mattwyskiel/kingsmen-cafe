//
//  QuickLink.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 5/25/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import Foundation

public struct QuickLink: Codable {
    public let name: String
    public let url: URL
    public let itemID: Int
    private enum CodingKeys: String, CodingKey {
        case name
        case url
        case itemID
    }
}
