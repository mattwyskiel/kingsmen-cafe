//
//  StoreProductDetailListViewHeader.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 4/3/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import UIKit
import Kingfisher
import Anchorage

final class StoreProductDetailListViewHeader: UIView {

    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    var productTypeLabel: UILabel = {
        let label = UILabel()
        let font = UIFont.systemFont(ofSize: 26, weight: .bold)
        label.font = UIFontMetrics(forTextStyle: UIFont.TextStyle.largeTitle).scaledFont(for: font)
        label.backgroundColor = .white
        return label
    }()

    var contentView: UIView = {
        let contentView = UIView()
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.backgroundColor = .white
        return contentView
    }()

    init(imageURL: URL?, categoryName: String) {
        imageView.kf.setImage(with: imageURL, placeholder: #imageLiteral(resourceName: "pourmikeys"))
        productTypeLabel.text = categoryName

        super.init(frame: .zero)

        backgroundColor = .white

        addSubview(contentView)
        addSubview(imageView)
        addSubview(productTypeLabel)

        setNeedsUpdateConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var shouldSetupConstraints = true
    override func updateConstraints() {
        if shouldSetupConstraints {
            // Configure Constraints

            contentView.edgeAnchors == safeAreaLayoutGuide.edgeAnchors

            imageView.widthAnchor == imageView.heightAnchor * 375/257
            imageView.trailingAnchor == contentView.trailingAnchor
            imageView.topAnchor == contentView.topAnchor
            productTypeLabel.topAnchor == imageView.bottomAnchor + 14
            productTypeLabel.leadingAnchor == contentView.layoutMarginsGuide.leadingAnchor
            contentView.trailingAnchor >= productTypeLabel.trailingAnchor
            contentView.bottomAnchor == productTypeLabel.bottomAnchor + 14
            imageView.leadingAnchor == contentView.leadingAnchor

            shouldSetupConstraints = false
        }
        super.updateConstraints()
    }

}
