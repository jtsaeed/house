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
import TwitterKit
import TwitterCore
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        firebaseSetup()
        notificationsSetup()
        clearIconBadge()
        
        TWTRTwitter.sharedInstance().start(withConsumerKey: "Q4CMl6PFvDgftelNDo9FQfonT", consumerSecret: "1M9dVB93VGUwpAWYNOGfutmwqdB0Buy6zAXJUQCamd8WE1h2Y7")
        
        
        displayLogin()
        
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
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        if let token = Messaging.messaging().fcmToken {
            DataService.instance.saveToken(token)
        }
    }
    
    private func firebaseSetup() {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        Database.database().isPersistenceEnabled = true
    }
    
    private func notificationsSetup() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (_, _) in }
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    private func clearIconBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    private func displayLogin() {
        if Auth.auth().currentUser == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let authVC = storyboard.instantiateViewController(withIdentifier: "InitialViewController")
            window?.makeKeyAndVisible()
            window?.rootViewController?.present(authVC, animated: true, completion: nil)
        }
    }
}

