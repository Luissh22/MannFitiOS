//
//  AppDelegate.swift
//  MannFit
//
//  Created by Luis Abraham on 2017-10-30.
//  Copyright © 2017 MannFit Labs. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // Override point for customization after application launch.
        UserDefaults.standard.register(defaults: [
            UserDefaultsKeys.settingsMotionSensitivityKey : 0.5,
            UserDefaultsKeys.settingsMusicKey : true,
            UserDefaultsKeys.settingsVolumeKey : 1.0,
            UserDefaultsKeys.settingsPongSpeedKey : 1.0
            ])
        
        let tabBarController = self.window?.rootViewController as! UITabBarController
      
        // Iterate through tab bar view controllers and set the managed object context
        for case let vc as CoreDataCompliant in tabBarController.viewControllers! {
            vc.managedObjectContext = CoreDataWrapper().managedObjectContext
        }
        
        // changes status bar in navigation bar to white color
        UINavigationBar.appearance().barStyle = .black
        // We can no longer pass the MOC directly because the history VC is embeded in a Nav controller
        if let navVC = tabBarController.viewControllers![1] as? UINavigationController {
            guard let historyVC = navVC.topViewController as? CoreDataCompliant else { return true }
            historyVC.managedObjectContext = CoreDataWrapper().managedObjectContext
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}
