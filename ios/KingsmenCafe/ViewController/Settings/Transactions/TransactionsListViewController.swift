//
//  TransactionsListViewController.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 7/12/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import UIKit

final class TransactionsListViewController: UITableViewController {

    let items: [OrderHistoryItem]
    var sortedItems: [String: [OrderHistoryItem]] = [:]

    weak var delegate: TransactionsListViewControllerDelegate?

    init(items: [OrderHistoryItem]) {
        self.items = items.sorted { $1.transaction.createdAt < $0.transaction.createdAt }
        for (idx, item) in self.items.enumerated() {

            let dayStringFormatter = DateFormatter()
            dayStringFormatter.dateFormat = "EEE., MMM. dd, y"
            let dayString = dayStringFormatter.string(from: item.transaction.createdAt)

            if idx == 0 {
                sortedItems[dayString] = [item]
            } else if let prev = self.items.itemIfExists(at: idx-1) {
                if Calendar.current.isDate(item.transaction.createdAt, inSameDayAs: prev.transaction.createdAt) {
                    sortedItems[dayString]!.append(item)
                } else {
                    sortedItems[dayString] = [item]
                }
            }
        }
        super.init(style: .plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Order History"
        tableView.register(UINib(nibName: "TransactionsListTableViewCell", bundle: nil), forCellReuseIdentifier: "TransactionsListTableViewCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sortedItems.keys.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = Array(sortedItems.keys)[section]
        return sortedItems[key]!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionsListTableViewCell", for: indexPath) as! TransactionsListTableViewCell

        // Configure the cell...
        let key = Array(sortedItems.keys)[indexPath.section]
        let item = sortedItems[key]![indexPath.row]
        cell.configure(with: item)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = Array(sortedItems.keys)[indexPath.section]
        let item = sortedItems[key]![indexPath.row]
        delegate?.transactionsListViewController(self, openTransaction: item)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Array(sortedItems.keys)[section]
    }
}

protocol TransactionsListViewControllerDelegate: class {
    func transactionsListViewController(_ viewController: TransactionsListViewController, openTransaction order: OrderHistoryItem)
}
