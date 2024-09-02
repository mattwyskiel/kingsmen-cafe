//
//  ScheduleClassResponse.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 3/28/19.
//  Copyright © 2019 Christian Heritage School. All rights reserved.
//

import Foundation

struct ScheduleClassResponse: Codable {
    let currentClass: ScheduleClass?
    enum ClassStatus: String, Codable {
        case `in`, next, dayOver, weekend
    }
    let classStatus: ClassStatus
}
