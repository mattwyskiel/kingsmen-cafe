//
//  NetworkError.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 3/5/19.
//  Copyright © 2019 Christian Heritage School. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case urlSessionError(Error)
    case encodingError(EncodingError)
    case badRequest(BackendMessage)
    case authenticationError
    case decodingError(DecodingError)
    case serverError(BackendMessage)
    case unrecognizedServerResponse(HTTPURLResponse)
    case noData(HTTPURLResponse)
    case noResponse
    case otherError(Error)
}

extension String: Error { }
