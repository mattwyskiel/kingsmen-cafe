//
//  ScheduleTermResponse.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 3/28/19.
//  Copyright © 2019 Christian Heritage School. All rights reserved.
//

import Foundation

enum ScheduleTerm: String, Codable {
    case sem1 = "S1"
    case sem2 = "S2"
    case winterim = "WIN"
    case christmasBreak = "XMAS"
    case summer = "SUM"
}

struct ScheduleTermResponse: Codable {
    let term: ScheduleTerm
    let startDate: String?
}
