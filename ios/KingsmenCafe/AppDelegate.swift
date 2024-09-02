//
//  AppDelegate.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 2/13/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import UIKit
import Instabug
import StoreKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
    var appCoordinator: AppCoordinator!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        let defaultView = LaunchScreenViewController()

        window?.rootViewController = defaultView
        window?.makeKeyAndVisible()

        Instabug.start(withToken: "XXXXXXXXXXXXXXXXXXXXXXXXX", invocationEvents: [.shake])

        appCoordinator = AppCoordinator(rootViewController: defaultView)
        SubscriptionManager.shared.initialize()
        appCoordinator.start()

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return AppOpenURLRouter().handle(url, appCoordinator)
    }

}
