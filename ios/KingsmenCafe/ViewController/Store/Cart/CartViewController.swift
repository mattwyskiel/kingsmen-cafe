//
//  CartViewController.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 4/5/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import UIKit

final class CartViewController: UITableViewController {

    var cartDidChangeToken: NSObjectProtocol!
    weak var delegate: CartViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        cartDidChangeToken = NotificationCenter.default.addObserver(forName: .cartDidChange, object: nil, queue: .main, using: { [tableView] _ in
            tableView?.reloadSections([0], with: .automatic)
        })

        let cellNib = UINib(nibName: "CartItemCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "CartItemCell")

        tableView.allowsMultipleSelectionDuringEditing = false

        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel(_:)))
        navigationItem.leftBarButtonItem = cancel

        title = "Cart"
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Cart.shared.items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartItemCell", for: indexPath) as! CartItemCell

        cell.initiallyConfigure(with: Cart.shared.items[indexPath.row])

        return cell
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = CartFooterView()
        view.delegate = self
        return view
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Cart.shared.items.remove(at: indexPath.row)
            //tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    @objc func cancel(_ sender: Any) {
        delegate?.cartViewControllerDidCancel(self)
    }

    deinit {
        if let token = cartDidChangeToken {
            NotificationCenter.default.removeObserver(token)
        }
    }
}

extension CartViewController: CartFooterViewDelegate {
    func addItemButtonPressed() {
        delegate?.cartViewControllerDidSelectAddItem(self)
    }

    func checkOutButtonPressed() {
        delegate?.cartViewControllerDidSelectCheckOut(self)
    }
}

protocol CartViewControllerDelegate: class {
    func cartViewControllerDidSelectAddItem(_ viewController: CartViewController)
    func cartViewControllerDidSelectCheckOut(_ viewController: CartViewController)
    func cartViewControllerDidCancel(_ viewController: CartViewController)
}
