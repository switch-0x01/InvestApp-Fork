//
//  AppDelegate.swift
//  My Portfolio
//
//  Created by Kirienko, Artem on 15.02.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var repository: DependencyRepository = .init()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let mainVC = MainViewController()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        UITabBar.appearance().tintColor = .systemGreen
        window?.overrideUserInterfaceStyle = .dark
        window?.rootViewController = mainVC
        window?.makeKeyAndVisible()
        
        if var mainVC = mainVC as? DependencyHolder {
            mainVC.repository = repository
        }
        
        return true
    }
}



