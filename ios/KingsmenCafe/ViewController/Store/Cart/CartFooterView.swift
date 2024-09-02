//
//  CartFooterView.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 4/5/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import UIKit
import PMSuperButton
import Anchorage

final class CartFooterView: UIView {
    let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        return view
    }()

    let addItemButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.lineBreakMode = .byTruncatingMiddle
        button.setTitle("Add Item...", for: .normal)
        return button
    }()

    let checkOutButton: PMSuperButton = {
        let superButton = PMSuperButton(type: .custom)
        superButton.titleLabel?.lineBreakMode = .byTruncatingMiddle
        superButton.titleLabel?.font = .systemFont(ofSize: 20)
        superButton.setTitle("Check Out", for: .normal)
        superButton.setTitleColor(UIColor(white: 1, alpha: 1), for: .normal)
        superButton.shadowColor = UIColor(white: 0, alpha: 1)
        superButton.cornerRadius = 14
        superButton.gradientEnabled = true
        superButton.gradientStartColor = UIColor(red: 0.0875, green: 0.231, blue: 0.518, alpha: 1)
        superButton.gradientEndColor = UIColor(red: 0.0875, green: 0.231, blue: 0.518, alpha: 1)
        superButton.shadowOpacity = 14
        superButton.shadowOffset = CGSize(width: -3, height: 3)
        superButton.shadowRadius = 14
        return superButton
    }()

    let superStackView: UIStackView = {
        let stackView1 = UIStackView()
        stackView1.axis = .vertical
        stackView1.spacing = 15
        return stackView1
    }()

    let subtotalTaxStackView: UIStackView = {
        let stackView2 = UIStackView()
        stackView2.axis = .vertical
        return stackView2
    }()

    let subtotalStackView: UIStackView = {
        let stackView3 = UIStackView()
        stackView3.spacing = 67
        return stackView3
    }()

    let subtotalTitleLabel: UILabel = {
        let label1 = UILabel()
        label1.text = "Subtotal"
        label1.textAlignment = .right
        label1.font = .systemFont(ofSize: 17)
        return label1
    }()

    let subtotalAmountLabel: UILabel = {
        let label2 = UILabel()
        label2.font = .systemFont(ofSize: 17)
        label2.textAlignment = .right
        label2.text = Cart.shared.subtotal.squareAmountAsCurrencyFormattedString
        return label2
    }()

    let taxStackView: UIStackView = {
        let stackView4 = UIStackView()
        stackView4.spacing = 67
        return stackView4
    }()

    let taxTitleLabel: UILabel = {
        let label3 = UILabel()
        label3.textAlignment = .right
        label3.text = "Tax"
        label3.font = .systemFont(ofSize: 17)
        return label3
    }()

    let taxAmountLabel: UILabel = {
        let label4 = UILabel()
        label4.textAlignment = .right
        label4.font = .systemFont(ofSize: 17)
        label4.text = Cart.shared.taxAmount.squareAmountAsCurrencyFormattedString
        return label4
    }()

    let totalStackView: UIStackView = {
        let stackView5 = UIStackView()
        stackView5.spacing = 68
        return stackView5
    }()

    let totalTitleLabel: UILabel = {
        let label5 = UILabel()
        label5.textAlignment = .right
        label5.text = "Total"
        label5.font = .boldSystemFont(ofSize: 17)
        return label5
    }()

    let totalAmountLabel: UILabel = {
        let label6 = UILabel()
        label6.textAlignment = .right
        label6.font = .systemFont(ofSize: 17)
        label6.text = Cart.shared.total.squareAmountAsCurrencyFormattedString
        return label6
    }()

    weak var delegate: CartFooterViewDelegate?
    init() {
        super.init(frame: .zero)
        addSubview(contentView)
        contentView.addSubview(addItemButton)
        contentView.addSubview(checkOutButton)
        contentView.addSubview(superStackView)

        superStackView.addArrangedSubview(subtotalTaxStackView)
        subtotalTaxStackView.addArrangedSubview(subtotalStackView)
        subtotalStackView.addArrangedSubview(subtotalTitleLabel)
        subtotalStackView.addArrangedSubview(subtotalAmountLabel)
        subtotalTaxStackView.addArrangedSubview(taxStackView)
        taxStackView.addArrangedSubview(taxTitleLabel)
        taxStackView.addArrangedSubview(taxAmountLabel)
        superStackView.addArrangedSubview(totalStackView)
        totalStackView.addArrangedSubview(totalTitleLabel)
        totalStackView.addArrangedSubview(totalAmountLabel)

        addItemButton.addTarget(self, action: #selector(addItemButtonPressed(_:)), for: .touchUpInside)
        checkOutButton.addTarget(self, action: #selector(checkOutButtonPressed(_:)), for: .touchUpInside)

        updateConstraintsIfNeeded()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var shouldSetupConstraints = true
    override func updateConstraints() {
        if shouldSetupConstraints {
            // Configure Constraints

            contentView.edgeAnchors == safeAreaLayoutGuide.edgeAnchors

            checkOutButton.heightAnchor == 54
            checkOutButton.widthAnchor == 332 ~ .high
            checkOutButton.trailingAnchor >= contentView.layoutMarginsGuide.trailingAnchor
            checkOutButton.bottomAnchor == contentView.bottomAnchor + 20
            checkOutButton.centerXAnchor == contentView.centerXAnchor
            checkOutButton.topAnchor == superStackView.bottomAnchor + 54
            superStackView.trailingAnchor == contentView.layoutMarginsGuide.trailingAnchor + 4
            checkOutButton.leadingAnchor >= contentView.layoutMarginsGuide.leadingAnchor
            addItemButton.topAnchor == contentView.topAnchor
            superStackView.topAnchor == addItemButton.bottomAnchor + 20
            addItemButton.trailingAnchor == contentView.layoutMarginsGuide.trailingAnchor

            shouldSetupConstraints = false
        }
        super.updateConstraints()
    }

    @objc func addItemButtonPressed(_ sender: Any) {
        delegate?.addItemButtonPressed()
    }

    @objc func checkOutButtonPressed(_ sender: Any) {
        delegate?.checkOutButtonPressed()
    }
}

protocol CartFooterViewDelegate: class {
    func addItemButtonPressed()
    func checkOutButtonPressed()
}
