//
//  Event.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 2/15/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import Foundation

struct Event: Codable {
    let id: String
    let name: String
    let startDate: Date
    let endDate: Date
    let location: String?
    let description: String?
}

enum EventCategory: String {
    case athleticsGames = "athletics-games"
    case allSchoolEvents = "all-school-events"
    case highSchoolEvents = "high-school-events"
    case middleSchoolEvents = "middle-school-events"
    case upperSchoolEvents = "upper-school-events"
    case missionsTrips = "missions-trips"
}
