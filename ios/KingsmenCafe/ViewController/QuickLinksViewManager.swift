//
//  QuickLinksManager.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 5/25/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import UIKit

final class QuickLinksViewManager: NSObject, UITableViewDataSource, UITableViewDelegate {
    var quickLinks: [QuickLink] = []
    weak var delegate: QuickLinksViewManagerDelegate?
    var tableView: UITableView

    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        setupTableView()
    }

    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "QuickLinksCell")

        reloadData()
    }

    func reloadData() {
        NetworkProvider().request(.myQuickLinks) { (result: NetworkProvider.Result<[QuickLink]>) in
            switch result {
            case .success(let links):
                self.quickLinks = links
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Quick Links"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quickLinks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuickLinksCell", for: indexPath)
        let quickLink = quickLinks[indexPath.row]
        cell.textLabel?.text = quickLink.name
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.quickLinksViewManager(self, open: quickLinks[indexPath.row])
    }

}

protocol QuickLinksViewManagerDelegate: class {
    func quickLinksViewManager(_ viewManager: QuickLinksViewManager, open quickLink: QuickLink)
}
