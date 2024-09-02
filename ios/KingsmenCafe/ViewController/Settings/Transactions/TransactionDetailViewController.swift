//
//  TransactionDetailViewController.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 7/12/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import UIKit

final class TransactionDetailViewController: UIViewController {

    @IBOutlet weak var transactionItemsView: UITableView!
    var dataSource: TransactionDetailTableViewDataSource

    let order: OrderHistoryItem
    weak var delegate: TransactionDetailViewControllerDelegate?

    init(order: OrderHistoryItem) {
        self.order = order
        dataSource = TransactionDetailTableViewDataSource(order: order)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Order Details"

        transactionItemsView.register(UINib(nibName: "TransactionDetailTableViewCell", bundle: nil),
                                      forCellReuseIdentifier: "TransactionDetailTableViewCell")
        transactionItemsView.dataSource = dataSource
        transactionItemsView.delegate = dataSource

        transactionItemsView.register(UINib.init(nibName: "TransactionDetailTableViewFooter", bundle: nil),
                                      forHeaderFooterViewReuseIdentifier: "TransactionDetailTableViewFooter")

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addItemsToCart(_ sender: Any) {
        delegate?.transactionDetailViewController(self, addItemsToCartFrom: order)
    }

    @IBAction func sendFeedback(_ sender: Any) {
        delegate?.transactionDetailViewController(self, sendFeedbackOn: order)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

protocol TransactionDetailViewControllerDelegate: class {
    func transactionDetailViewController(_ viewController: TransactionDetailViewController, addItemsToCartFrom order: OrderHistoryItem)
    func transactionDetailViewController(_ viewController: TransactionDetailViewController, sendFeedbackOn order: OrderHistoryItem)
}

final class TransactionDetailTableViewDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let lineItem = order.checkout.order.lineItems[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionDetailTableViewCell", for: indexPath) as! TransactionDetailTableViewCell
        cell.configure(with: lineItem)
        return cell
    }

    var order: OrderHistoryItem
    init(order: OrderHistoryItem) {
        self.order = order
        super.init()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return order.checkout.order.lineItems.count
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TransactionDetailTableViewFooter")
            as! TransactionDetailTableViewFooter
        footerView.configure(with: order)
        return footerView
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 120
    }

}
