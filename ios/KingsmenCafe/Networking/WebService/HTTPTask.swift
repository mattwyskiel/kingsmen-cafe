//
//  HTTPTask.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 3/5/19.
//  Copyright © 2019 Christian Heritage School. All rights reserved.
//

import Foundation

public typealias HTTPHeaders = [String: String]

public enum ParameterEncoding {
    case json(Parameters)
    case url(Parameters)
}

public enum HTTPTask {
    case plain
    case requestWithParameters(ParameterEncoding)
    case requestWithData(Data)
}
