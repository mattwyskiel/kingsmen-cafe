//
//  ScheduleClass.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 3/28/19.
//  Copyright © 2019 Christian Heritage School. All rights reserved.
//

import Foundation

struct ScheduleBlock: Codable {
    let day: String // [M, T, W, R, F]
    let startTime: String // ISO formatted
    let endTime: String // ISO formatted
}

struct ScheduleClass: Codable {
    let renWebID: Int
    let courseName: String
    let section: String
    let term: [ScheduleTerm] // S1, S2, WIN
    let teacherID: Int
    let schedule: [ScheduleBlock]
}
