//
//  HomeViewModelTests.swift
//  KingsmenCafeTests
//
//  Created by Matthew Wyskiel on 4/19/19.
//  Copyright © 2019 Christian Heritage School. All rights reserved.
//

import XCTest
@testable import KingsmenCafe

class HomeViewModelTests: XCTestCase {

    let viewModel = HomeViewModel()

    private func date(day: Int? = nil, month: Int? = nil, year: Int? = nil, hour: Int? = nil, minute: Int? = nil) -> Date {
        let components = DateComponents(calendar: .current, timeZone: .current, year: year, month: month, day: day, hour: hour, minute: minute)
        return components.date!
    }

    private func classResponse(withStatus status: ScheduleClassResponse.ClassStatus = .in) -> ScheduleClassResponse {
        let classResponseJSON = """
        {
            "currentClass": {
                "term":["S1","S2"],
                "_id":"5cb2a64a02a4764b28d98ec8",
                "renWebID":4945,
                "__v":0,
                "courseName":"Christian Worldview and Ethics",
                "schedule": [
                    {"day":"M","startTime":"12:49:00","endTime":"13:39:00"},
                    {"day":"T","startTime":"12:49:00","endTime":"13:39:00"},
                    {"day":"W","startTime":"10:34:00","endTime":"11:51:00"},
                    {"day":"F","startTime":"12:49:00","endTime":"13:39:00"}
                ],
                "section":"8610-WLETH-2",
                "teacherID":1204911
            },
            "classStatus":"\(status.rawValue)"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(webServiceDateDecoder)
        return try! decoder.decode(ScheduleClassResponse.self, from: classResponseJSON)
    }

    func testGetNextClassTime() {
        let monday = date(day: 15, month: 4, year: 2019) // Friday
        let localizedClassTimeM = viewModel.getNextClassTime(for: classResponse().currentClass!, monday)

        XCTAssertEqual(localizedClassTimeM, "12:49 PM")

        let tuesday = date(day: 16, month: 4, year: 2019) // Friday
        let localizedClassTimeT = viewModel.getNextClassTime(for: classResponse().currentClass!, tuesday)

        XCTAssertEqual(localizedClassTimeT, "12:49 PM")

        let wednesday = date(day: 17, month: 4, year: 2019) // Friday
        let localizedClassTimeW = viewModel.getNextClassTime(for: classResponse().currentClass!, wednesday)

        XCTAssertEqual(localizedClassTimeW, "10:34 AM")

        let friday = date(day: 19, month: 4, year: 2019) // Friday
        let localizedClassTimeF = viewModel.getNextClassTime(for: classResponse().currentClass!, friday)

        XCTAssertEqual(localizedClassTimeF, "12:49 PM")
    }

    func testNextClassText() {
        let weekday = date(day: 19, month: 4, year: 2019) // Friday
        // classStatus is In
        let inText = viewModel.nextClassText(for: classResponse())
        XCTAssertEqual(inText, "You are currently in Christian Worldview and Ethics.")

        let nextText = viewModel.nextClassText(for: classResponse(withStatus: .next), weekday)
        XCTAssertEqual(nextText, "Your next class is Christian Worldview and Ethics. It starts at 12:49 PM.")

        let dayOverText = viewModel.nextClassText(for: classResponse(withStatus: .dayOver))
        XCTAssertEqual(dayOverText, "No more classes for today!")

        let weekendText = viewModel.nextClassText(for: classResponse(withStatus: .weekend))
        XCTAssertEqual(weekendText, "It's the weekend!")
    }

    func testGenerateGreeting() {
        let morning = date(day: 19, month: 4, year: 2019, hour: 11) // 11am
        let afternoon = date(day: 19, month: 4, year: 2019, hour: 16) // 4pm
        let evening = date(day: 19, month: 4, year: 2019, hour: 20) // 4pm
        let name = "Matt"

        let morningGreeting = viewModel.generateGreeting(name: name, from: morning)
        XCTAssertEqual(morningGreeting, "Good Morning, Matt")

        let afternoonGreeting = viewModel.generateGreeting(name: name, from: afternoon)
        XCTAssertEqual(afternoonGreeting, "Good Afternoon, Matt")

        let eveningGreeting = viewModel.generateGreeting(name: name, from: evening)
        XCTAssertEqual(eveningGreeting, "Good Evening, Matt")
    }

    func testGenerateDateString() {
        let sunday = date(day: 11, month: 8, year: 2019)
        let monday = date(day: 4, month: 2, year: 2019)
        let tuesday = date(day: 11, month: 6, year: 2019)
        let wednesday = date(day: 18, month: 3, year: 2020)
        let thursday = date(day: 31, month: 10, year: 2019)
        let friday = date(day: 19, month: 4, year: 2019)
        let saturday = date(day: 18, month: 5, year: 2019)

        XCTAssertEqual(viewModel.generateDateString(sunday), "Sunday, August 11, 2019")
        XCTAssertEqual(viewModel.generateDateString(monday), "Monday, February 4, 2019")
        XCTAssertEqual(viewModel.generateDateString(tuesday), "Tuesday, June 11, 2019")
        XCTAssertEqual(viewModel.generateDateString(wednesday), "Wednesday, March 18, 2020")
        XCTAssertEqual(viewModel.generateDateString(thursday), "Thursday, October 31, 2019")
        XCTAssertEqual(viewModel.generateDateString(friday), "Friday, April 19, 2019")
        XCTAssertEqual(viewModel.generateDateString(saturday), "Saturday, May 18, 2019")
    }

    func testGetBreakText() {
        XCTAssertEqual(viewModel.getBreakText(for: .christmasBreak), "Merry Christmas!")
        XCTAssertEqual(viewModel.getBreakText(for: .sem1), "")
        XCTAssertEqual(viewModel.getBreakText(for: .sem2), "")
        XCTAssertEqual(viewModel.getBreakText(for: .summer), "We are currently on Summer Vacation.")
        XCTAssertEqual(viewModel.getBreakText(for: .winterim), "")
    }

}
