//
//  SettingsRootViewController.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 3/28/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import UIKit
import Static
import Anchorage

final class SettingsRootViewController: TableViewController {

    weak var delegate: SettingsRootViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()

        let footer = footerView()
        dataSource.sections = [
            Section(header: "User Account", rows: [
                Row(text: "Edit Profile", selection: { [unowned self] in
                    self.delegate?.settingsRootViewControllerOpenAccountSettings(self)
                }, accessory: .disclosureIndicator),
                Row(text: "View Order History", selection: { [unowned self] in
                    // view transactions
                    self.delegate?.settingsRootViewControllerOpenTransactionsList(self)
                }, accessory: .disclosureIndicator),
                Row(text: "Sign Out", selection: {
                    self.delegate?.settingsRootViewControllerSignOut(self)
                }, cellClass: ButtonCell.self) ]), /*,
                Row(text: "Manage Quick Links", selection: {
                    // manage quick links
                }, accessory: .disclosureIndicator)*/
            /*]),
             Section(header: "App Settings", rows: [
                Row(text: "Manage Subscriptions", selection: {
                    // manage push notifications
                    self.delegate?.settingsRootViewControllerOpenSubscriptionManagement(self)
                }, accessory: .disclosureIndicator)
            ]), */
            Section(header: "Who We Are", rows: [
                Row(text: "Pour Mikey's Coffee", selection: { [unowned self] in
                    // about Pour Mikey's
                    self.delegate?.settingsRootViewController(self, openWhoWeAreScreenFor: .pourMikeys)
                }, accessory: .disclosureIndicator) /*
                Row(text: "Kingsmen Café", selection: {
                    // about Kingsmen Café company/business class
                }, accessory: .disclosureIndicator)*/
            ]),
            Section(header: "About the App", rows: [
                Row(text: "Third Party Libraries", selection: { [unowned self] in
                    // third party library acknowledgements
                    self.delegate?.settingsRootViewControllerOpenThirdPartyAcknowledgements(self)
                }, accessory: .disclosureIndicator)
            ], footer: .autoLayoutView(footer))
        ]

        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done(_:)))
        navigationItem.rightBarButtonItem = doneButton
    }

    @objc func done(_ sender: UIBarButtonItem) {
        delegate?.settingsRootViewControllerDidFinish(self)
    }

    func footerView() -> UIView {
        let kingsmenCafeLabel = UILabel()
        kingsmenCafeLabel.text = "Kingsmen Café"
        kingsmenCafeLabel.textAlignment = .center

        let versionLabel = UILabel()
        // swiftlint:disable line_length
        versionLabel.text = "Version \(Bundle.main.infoDictionary!["CFBundleShortVersionString"]!) (\(Bundle.main.infoDictionary!["CFBundleVersion"]!))"
        // swiftlint:enable line_length
        versionLabel.textAlignment = .center

        let copyrightLabel = UILabel()
        copyrightLabel.text = "Copyright © 2018 Kingsmen Café"
        copyrightLabel.textAlignment = .center

        let stackView = UIStackView(arrangedSubviews: [kingsmenCafeLabel, versionLabel, copyrightLabel])
        stackView.backgroundColor = .clear
        stackView.axis = .vertical

        let superView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: stackView.intrinsicContentSize.height))
        superView.backgroundColor = .clear
        superView.addSubview(stackView)

        stackView.edgeAnchors == superView.edgeAnchors

        return superView
    }

    enum WhoWeAreOption {
        case pourMikeys
        case kingsmenCafe
    }
}

protocol SettingsRootViewControllerDelegate: class {
    func settingsRootViewControllerOpenAccountSettings(_ viewController: SettingsRootViewController)
    func settingsRootViewControllerOpenTransactionsList(_ viewController: SettingsRootViewController)
    func settingsRootViewController(_ viewController: SettingsRootViewController,
                                    openWhoWeAreScreenFor option: SettingsRootViewController.WhoWeAreOption)
    func settingsRootViewControllerOpenThirdPartyAcknowledgements(_ viewController: SettingsRootViewController)
    func settingsRootViewControllerDidFinish(_ viewController: SettingsRootViewController)
    func settingsRootViewControllerSignOut(_ viewController: SettingsRootViewController)
    func settingsRootViewControllerOpenSubscriptionManagement(_ viewController: SettingsRootViewController)
}
