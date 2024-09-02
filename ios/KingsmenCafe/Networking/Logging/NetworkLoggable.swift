//
//  Loggable.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 3/5/19.
//  Copyright © 2019 Christian Heritage School. All rights reserved.
//

import Foundation

protocol NetworkLoggable {
    func willBeginRequest(_ request: URLRequest)
    func didReceiveResponse(_ data: Data?, _ response: HTTPURLResponse?, _ error: Error?)
}
