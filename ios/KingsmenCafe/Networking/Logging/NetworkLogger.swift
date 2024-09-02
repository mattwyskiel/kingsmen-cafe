//
//  NetworkLogger.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 3/5/19.
//  Copyright © 2019 Christian Heritage School. All rights reserved.
//

import Foundation

class NetworkLogger: NetworkLoggable {
    func willBeginRequest(_ request: URLRequest) {
        print("\(request.httpMethod ?? "GET") \(String(describing: request.url?.absoluteString))")
        if let body = request.httpBody {
            print("Body:")
            print(String(data: body, encoding: .utf8) ?? "")
        }
        print("Headers: \(String(describing: request.allHTTPHeaderFields))")
    }

    func didReceiveResponse(_ data: Data?, _ response: HTTPURLResponse?, _ error: Error?) {
        if let response = response {
            print(response.statusCode)
            print(response.mimeType ?? "")
        } else {
            print("no response")
        }

        if let data = data {
            print(String(data: data, encoding: .utf8) ?? "")
        } else {
            print("no data")
        }

    }

}
