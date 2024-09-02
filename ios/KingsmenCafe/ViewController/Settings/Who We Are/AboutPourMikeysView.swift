//
//  AboutPourMikeysView.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 8/2/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import UIKit
import Static

final class AboutPourMikeysView: UIView {
    @IBOutlet weak var linksView: UITableView!

    weak var delegate: AboutPourMikeysViewDelegate?

    var dataSource: DataSource!

    override func awakeFromNib() {
        super.awakeFromNib()

        dataSource = DataSource(tableView: linksView, sections: [
            Section(rows: [
                row(withLabel: "www.pourmikeyscoffee.com", icon: #imageLiteral(resourceName: "globe-net-icon"), link: .web),
                row(withLabel: "/pourmikeyscoffee", icon: #imageLiteral(resourceName: "facebook-logo"), link: .facebook),
                row(withLabel: "@pourmikeyscoffee", icon: #imageLiteral(resourceName: "IG_Glyph_Fill"), link: .instagram)
            ])
        ])

    }

    enum Link: String {
        case web = "https://www.pourmikeyscoffee.com"
        case facebook = "https://www.facebook.com/pourmikeyscoffee"
        case instagram = "https://www.instagram.com/pourmikeyscoffee"
    }

    private func row(withLabel label: String, icon: UIImage, link: Link) -> Row {
        return Row(selection: { [unowned self] in
            self.delegate?.aboutPourMikeysView(self, open: link)
            }, accessory: .disclosureIndicator, cellClass: LinkView.self, context: ["label": label,
                                               "icon": icon])
    }

}

protocol AboutPourMikeysViewDelegate: class {
    func aboutPourMikeysView(_ view: AboutPourMikeysView, open link: AboutPourMikeysView.Link)
}
