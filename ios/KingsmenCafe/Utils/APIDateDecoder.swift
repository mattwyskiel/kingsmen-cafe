//
//  APIDateDecoder.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 3/5/19.
//  Copyright © 2019 Christian Heritage School. All rights reserved.
//

import Foundation

enum DateDecodingError: Error {
    case invalidString
}

func webServiceDateDecoder(_ decoder: Decoder) throws -> Date {
    let container = try decoder.singleValueContainer()
    let milliescondFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SS'Z'"
        return formatter
    }()
    let secondFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return formatter
    }()
    let dateString = try container.decode(String.self)
    if let date = milliescondFormatter.date(from: dateString) {
        return date
    } else if let date = secondFormatter.date(from: dateString) {
        return date
    } else {
        throw DateDecodingError.invalidString
    }
}
