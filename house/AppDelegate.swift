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
import Intents

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {

    var window: UIWindow?
    var tab: Int?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        firebaseSetup()
        notificationsSetup()
        
        TWTRTwitter.sharedInstance().start(withConsumerKey: "Q4CMl6PFvDgftelNDo9FQfonT", consumerSecret: "1M9dVB93VGUwpAWYNOGfutmwqdB0Buy6zAXJUQCamd8WE1h2Y7")
        
        checkAuthentication()
        
        /*
        let myTabBar = self.window?.rootViewController as! UITabBarController // Getting Tab Bar
        myTabBar.selectedIndex = 2
 */
        
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
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let aps = userInfo["aps"] as? NSDictionary {
            if let alert = aps["alert"] as? NSDictionary {
                print(alert["title"])
            }
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
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
    
    private func checkAuthentication() {
        if Auth.auth().currentUser == nil {
            displayLogin()
        } else {
            DataService.instance.checkIfUserRegistered { (registered) in
                if !registered {
                    do {
                        try Auth.auth().signOut()
                        self.displayLogin()
                    } catch let signOutError as NSError {
                        // TODO: Comprehensive Error
                    }
                }
            }
        }
    }
    
    private func displayLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let authVC = storyboard.instantiateViewController(withIdentifier: "InitialViewController")
        self.window?.makeKeyAndVisible()
        self.window?.rootViewController?.present(authVC, animated: true, completion: nil)
    }
}

