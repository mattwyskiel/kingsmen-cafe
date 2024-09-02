//
//  HomeViewController.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 3/27/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import UIKit
import Anchorage
import PMSuperButton

final class HomeViewController: UIViewController {
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var quickLinksTableView: UITableView!
    @IBOutlet weak var quickLinksCardView: CardView!
    @IBOutlet weak var orderNowButton: PMSuperButton!
    @IBOutlet weak var nextClassLabel: UILabel!

    let viewModel = HomeViewModel()

    weak var delegate: HomeViewControllerDelegate?
    var userInfo: UserInfo {
        didSet {
            updateUI()
        }
    }
    var currentClass: ScheduleClassResponse?
    var currentTerm: ScheduleTermResponse?

    var quickLinksViewManager: QuickLinksViewManager!

    init(userInfo: UserInfo, currentClass: ScheduleClassResponse?, currentTerm: ScheduleTermResponse?) {
        self.currentClass = currentClass
        self.currentTerm = currentTerm
        self.userInfo = userInfo
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        updateUI()
    }

    func updateUI() {
        let nickName: String = (userInfo.nickName != nil && userInfo.nickName != "") ? userInfo.nickName! : userInfo.firstName
        greetingLabel.text = viewModel.generateGreeting(name: nickName)
        dateLabel.text = "Today is " + viewModel.generateDateString() + "."

        quickLinksViewManager = QuickLinksViewManager(tableView: quickLinksTableView)
        quickLinksViewManager.delegate = self

        if let termResponse = currentTerm {

            switch termResponse.term {
            case .sem1, .sem2, .winterim:
                // currently should have class
                if let classResponse = currentClass {
                    nextClassLabel.text = viewModel.nextClassText(for: classResponse)
                }
            default:
                nextClassLabel.text = viewModel.getBreakText(for: termResponse.term)
            }

        }

//        if traitCollection.userInterfaceIdiom == .pad {
//            quickLinksCardView.heightAnchor.constraint(equalToConstant: 400).isActive = true
//        } else if traitCollection.userInterfaceIdiom == .phone {
//            quickLinksCardView.bottomAnchor.constraint(equalTo: orderNowButton.topAnchor, constant: 16)
//        }
    }

    @IBAction func openSettings(_ sender: Any) {
        delegate?.homeViewControllerOpenSettings(self)
    }
    @IBAction func orderNow(_ sender: Any) {
        delegate?.homeViewControllerOpenStore(self)
    }
    @IBAction func presentCashAppInfo(_ sender: Any) {
        delegate?.homeViewControllerPresentCashAppInfo(self)
    }
}

extension HomeViewController: QuickLinksViewManagerDelegate {
    func quickLinksViewManager(_ viewManager: QuickLinksViewManager, open quickLink: QuickLink) {
        delegate?.homeViewController(self, open: quickLink)
    }
}

protocol HomeViewControllerDelegate: class {
    func homeViewControllerOpenSettings(_ viewController: HomeViewController)
    func homeViewControllerOpenStore(_ viewController: HomeViewController)
    func homeViewControllerPresentCashAppInfo(_ viewController: HomeViewController)
    func homeViewController(_ viewController: HomeViewController, open quickLink: QuickLink)
}
