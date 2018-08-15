//
//  AppDelegate.swift
//  house
//
//  Created by James Saeed on 09/05/2018.
//  Copyright © 2018 James Saeed. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseUI
import IQKeyboardManagerSwift
import UserNotifications
import HousePalsCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {

    var window: UIWindow?
    var tab: Int?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        firebaseSetup()
        checkAuthentication()
        misc()
        
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
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let aps = userInfo["aps"] as? NSDictionary {
            if let alert = aps["alert"] as? NSDictionary {
                if let title = alert["title"] as? String {
                    handleNotification(for: title)
                }
            }
        }
    }

    private func handleNotification(for title: String) {
        let tabBar = self.window?.rootViewController as! UITabBarController
        
        if title == "New Chore" {
            tabBar.selectedIndex = 1
        }
        if title == "New Debt" {
            tabBar.selectedIndex = 2
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        return false
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        if let token = Messaging.messaging().fcmToken {
            DataService.instance.saveToken(token)
        }
    }
    
    private func misc() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        IQKeyboardManager.shared.enable = true
    }
    
    private func firebaseSetup() {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        Database.database().isPersistenceEnabled = true
    }
    
    private func checkAuthentication() {
        let userDefaults = UserDefaults.standard
        if userDefaults.value(forKey: "appFirstTimeOpend") == nil {
            userDefaults.setValue(true, forKey: "appFirstTimeOpend")
            do {
                try Auth.auth().signOut()
            } catch let error {
                print(error.localizedDescription)
            }
        }
        
        if Auth.auth().currentUser == nil {
            displayLogin()
        } else {
            DataService.instance.checkIfUserRegistered { (registered) in
                if !registered {
                    self.displayPrepareHouse()
                }
            }
        }
    }
    
    private func displayLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let authVC = storyboard.instantiateViewController(withIdentifier: "InitialViewController")
        self.window?.makeKeyAndVisible()
        self.window?.rootViewController?.present(authVC, animated: false, completion: nil)
    }
    
    private func displayPrepareHouse() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let prepareHouseVC = storyboard.instantiateViewController(withIdentifier: "PrepareHouseViewController")
        self.window?.makeKeyAndVisible()
        self.window?.rootViewController?.present(prepareHouseVC, animated: false, completion: nil)
    }
}

