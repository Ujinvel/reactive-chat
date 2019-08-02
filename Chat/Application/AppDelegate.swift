//
//  AppDelegate.swift
//  Chat
//
//  Created by Ujin on 7/31/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    private lazy var platform = Platform(configuration: Environment.current)
    private lazy var appCoordinator = ApplicationCoordinator(useCases: self.platform)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        platform.didFinishLaunching(with: launchOptions)
        window = appCoordinator.window
        return true
    }
}

