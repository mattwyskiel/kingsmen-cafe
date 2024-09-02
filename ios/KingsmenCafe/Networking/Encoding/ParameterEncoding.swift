//
//  ParameterEncoding.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 3/5/19.
//  Copyright © 2019 Christian Heritage School. All rights reserved.
//

import Foundation

public typealias Parameters = [String: Any]

public protocol ParameterEncoder {
    static func encode(_ urlRequest: inout URLRequest, with parameters: Parameters) throws
}

public enum EncodingError: Error {
    case parametersNil
    case encodingFailed(error: Error)
    case missingURL
}
