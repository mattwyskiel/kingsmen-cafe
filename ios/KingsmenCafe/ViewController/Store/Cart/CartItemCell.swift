//
//  CartItemCell.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 4/4/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import UIKit
import Kingfisher

final class CartItemCell: UITableViewCell {

    weak var cartItem: CartItem?
    let cellQuantityManager = CartItemCellQuantityManager()

    func initiallyConfigure(with cartItem: CartItem) {
        itemImageView.kf.setImage(with: cartItem.imageURL, placeholder: #imageLiteral(resourceName: "pourmikeys"))
        itemNameLabel.text = cartItem.name
        configureWithQuantity(from: cartItem)
        //self.cartItem = cartItem set in configureWithQuantity(from:)
    }

    func configureWithQuantity(from cartItem: CartItem) {
        itemPriceLabel.text = cartItem.fullPrice.squareAmountAsCurrencyFormattedString
        itemQuantityLabel.text = String(cartItem.quantity)
        self.cartItem = cartItem
    }

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    @IBOutlet weak var itemQuantityLabel: UILabel!

    @IBAction func increaseQuantity(_ sender: Any) {
        cellQuantityManager.increaseQuantity(cartItem: cartItem!, cell: self)
    }
    @IBAction func decreaseQuantity(_ sender: Any) {
        cellQuantityManager.decreaseQuantity(cartItem: cartItem!, cell: self)
    }
}

final class CartItemCellQuantityManager {
    func increaseQuantity(cartItem: CartItem, cell: CartItemCell) {
        cartItem.quantity += 1
        cell.configureWithQuantity(from: cartItem)
    }
    func decreaseQuantity(cartItem: CartItem, cell: CartItemCell) {
        cartItem.quantity -= 1
        cell.configureWithQuantity(from: cartItem)
    }
}
