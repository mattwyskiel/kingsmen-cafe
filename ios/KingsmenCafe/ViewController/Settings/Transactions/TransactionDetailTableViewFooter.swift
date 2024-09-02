//
//  TransactionDetailTableViewFooter.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 7/12/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import UIKit

final class TransactionDetailTableViewFooter: UITableViewHeaderFooterView {
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var subtotalLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!

    func configure(with order: OrderHistoryItem) {
        taxLabel.text = order.checkout.order.totalTaxMoney.amount.squareAmountAsCurrencyFormattedString
        subtotalLabel.text = order.checkout.order.lineItems
                    .map { $0.basePriceMoney.amount }
                    .reduce(0, +).squareAmountAsCurrencyFormattedString
        totalLabel.text = order.checkout.order.totalMoney.amount.squareAmountAsCurrencyFormattedString
    }

}

//import Anchorage
//
//final class TransactionDetailTableViewFooter: UIView {
//    let contentView: UIView = {
//        let view = UIView()
//        view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
//        return view
//    }()
//
//    let superStackView: UIStackView = {
//        let stackView1 = UIStackView()
//        stackView1.axis = .vertical
//        stackView1.spacing = 15
//        return stackView1
//    }()
//
//    let subtotalTaxStackView: UIStackView = {
//        let stackView2 = UIStackView()
//        stackView2.axis = .vertical
//        return stackView2
//    }()
//
//    let subtotalStackView: UIStackView = {
//        let stackView3 = UIStackView()
//        stackView3.spacing = 67
//        return stackView3
//    }()
//
//    let subtotalTitleLabel: UILabel = {
//        let label1 = UILabel()
//        label1.text = "Subtotal"
//        label1.textAlignment = .right
//        label1.font = .systemFont(ofSize: 17)
//        return label1
//    }()
//
//    let subtotalAmountLabel: UILabel = {
//        let label2 = UILabel()
//        label2.font = .systemFont(ofSize: 17)
//        label2.textAlignment = .right
//        return label2
//    }()
//
//    let taxStackView: UIStackView = {
//        let stackView4 = UIStackView()
//        stackView4.spacing = 67
//        return stackView4
//    }()
//
//    let taxTitleLabel: UILabel = {
//        let label3 = UILabel()
//        label3.textAlignment = .right
//        label3.text = "Tax"
//        label3.font = .systemFont(ofSize: 17)
//        return label3
//    }()
//
//    let taxAmountLabel: UILabel = {
//        let label4 = UILabel()
//        label4.textAlignment = .right
//        label4.font = .systemFont(ofSize: 17)
//        return label4
//    }()
//
//    let totalStackView: UIStackView = {
//        let stackView5 = UIStackView()
//        stackView5.spacing = 68
//        return stackView5
//    }()
//
//    let totalTitleLabel: UILabel = {
//        let label5 = UILabel()
//        label5.textAlignment = .right
//        label5.text = "Total"
//        label5.font = .boldSystemFont(ofSize: 17)
//        return label5
//    }()
//
//    let totalAmountLabel: UILabel = {
//        let label6 = UILabel()
//        label6.textAlignment = .right
//        label6.font = .systemFont(ofSize: 17)
//        return label6
//    }()
//
//    weak var delegate: CartFooterViewDelegate?
//    init(order: OrderHistoryItem) {
//        super.init(frame: .zero)
//        addSubview(contentView)
//        contentView.addSubview(superStackView)
//
//        superStackView.addArrangedSubview(subtotalTaxStackView)
//        subtotalTaxStackView.addArrangedSubview(subtotalStackView)
//        subtotalStackView.addArrangedSubview(subtotalTitleLabel)
//
//        subtotalAmountLabel.text = order.checkout.order.lineItems
//            .map { $0.basePriceMoney.amount }
//            .reduce(0, +).squareAmountAsCurrencyFormattedString
//        subtotalStackView.addArrangedSubview(subtotalAmountLabel)
//
//        subtotalTaxStackView.addArrangedSubview(taxStackView)
//        taxStackView.addArrangedSubview(taxTitleLabel)
//
//        taxAmountLabel.text = order.checkout.order.totalTaxMoney.amount.squareAmountAsCurrencyFormattedString
//        taxStackView.addArrangedSubview(taxAmountLabel)
//
//        superStackView.addArrangedSubview(totalStackView)
//        totalStackView.addArrangedSubview(totalTitleLabel)
//
//        totalAmountLabel.text = order.checkout.order.totalMoney.amount.squareAmountAsCurrencyFormattedString
//        totalStackView.addArrangedSubview(totalAmountLabel)
//
//        updateConstraintsIfNeeded()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private var shouldSetupConstraints = true
//    override func updateConstraints() {
//        if shouldSetupConstraints {
//            // Configure Constraints
//
//            contentView.edgeAnchors == safeAreaLayoutGuide.edgeAnchors
//            superStackView.bottomAnchor == contentView.safeAreaLayoutGuide.bottomAnchor + 15
//            superStackView.trailingAnchor == contentView.layoutMarginsGuide.trailingAnchor + 4
//            superStackView.topAnchor == contentView.safeAreaLayoutGuide.topAnchor + 15
//            //superStackView.leadingAnchor >= contentView.safeAreaLayoutGuide.leadingAnchor
//
//            heightAnchor == 107
//
//            shouldSetupConstraints = false
//        }
//        super.updateConstraints()
//    }
//}
