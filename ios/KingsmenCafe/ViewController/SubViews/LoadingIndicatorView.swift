//
//  LoadingIndicatorView.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 3/27/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//
// swiftlint:disable identifier_name

import UIKit

func LoadingIndicatorView() -> UIAlertController {
    let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)

    let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
    loadingIndicator.hidesWhenStopped = true
    loadingIndicator.style = UIActivityIndicatorView.Style.gray
    loadingIndicator.startAnimating()

    alert.view.addSubview(loadingIndicator)
    return alert
}
