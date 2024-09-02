//
//  StoreProductDetailListViewController.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 4/3/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import UIKit
import Kingfisher

final class StoreProductDetailListViewController: UITableViewController {

    var items: [SquareCatalogItem.ItemData.Variation]
    var headerImageURL: URL?
    var productType: String
    weak var delegate: StoreProductDetailListViewControllerDelegate?

    init(items: [SquareCatalogItem.ItemData.Variation], productType: String, headerImageURL: URL?) {
        self.items = items
        self.headerImageURL = headerImageURL
        self.productType = productType
        super.init(style: .plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(StoreProductDetailCell.self, forCellReuseIdentifier: "ProductCell")
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! StoreProductDetailCell

        // Configure the cell...
        let item = items[indexPath.row]
        cell.textLabel?.text = item.itemVariationData.name
        cell.detailTextLabel?.text = item.itemVariationData.priceMoney?.amount.squareAmountAsCurrencyFormattedString

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.storeProductDetailListViewController(self, didSelect: items[indexPath.row], imageURL: headerImageURL)
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return StoreProductDetailListViewHeader(imageURL: headerImageURL, categoryName: productType)
    }

}

protocol StoreProductDetailListViewControllerDelegate: class {
    func storeProductDetailListViewController(_ controller: StoreProductDetailListViewController,
                                              didSelect item: SquareCatalogItem.ItemData.Variation,
                                              imageURL: URL?)
}

final class StoreProductDetailCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
