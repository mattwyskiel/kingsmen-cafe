//
//  HomeViewModel.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 4/19/19.
//  Copyright © 2019 Christian Heritage School. All rights reserved.
//

import Foundation

class HomeViewModel {
    func getNextClassTime(for nextClass: ScheduleClass, _ today: Date = Date()) -> String {
        let weekday = Calendar.current.component(.weekday, from: today)
        let mapping = ["S", "M", "T", "W", "R", "F", "S"]
        let mappedWeekday = mapping[weekday-1]

        let nextClassBlock = nextClass.schedule.filter { $0.day == mappedWeekday }[0]
        let nextClassStartTime = nextClassBlock.startTime

        let todayFormatter = ISO8601DateFormatter()
        todayFormatter.formatOptions = [.withColonSeparatorInTime, .withTime]
        todayFormatter.timeZone = .current
        if let nextClassStartDate = todayFormatter.date(from: nextClassStartTime) {

            let timeFormatter = DateFormatter()
            timeFormatter.dateStyle = .none
            timeFormatter.timeStyle = .short
            timeFormatter.timeZone = .current

            return timeFormatter.string(from: nextClassStartDate)
        } else {
            return nextClassStartTime
        }
    }

    func nextClassText(for classResponse: ScheduleClassResponse, _ date: Date = Date()) -> String {
        switch classResponse.classStatus {
        case .in:
            return "You are currently in \(classResponse.currentClass!.courseName)."
        case .next:
            let next = classResponse.currentClass!
            return "Your next class is \(classResponse.currentClass!.courseName). It starts at \(getNextClassTime(for: next, date))."
        case .dayOver:
            return "No more classes for today!"
        case .weekend:
            return "It's the weekend!"
        }
    }

    func generateGreeting(name: String, from date: Date = Date()) -> String {
        let hour = Calendar.current.component(.hour, from: date)
        if hour >= 0 && hour < 12 {
            return "Good Morning, \(name)"
        } else if hour >= 12 && hour < 18 {
            return "Good Afternoon, \(name)"
        } else {
            return "Good Evening, \(name)"
        }
    }

    func generateDateString(_ date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: date)
    }

    func getBreakText(for term: ScheduleTerm) -> String {
        switch term {
        case .christmasBreak:
            return "Merry Christmas!"
        case .summer:
            return "We are currently on Summer Vacation."
        default:
            return ""
        }
    }
}
