//
//  AppDelegate.swift
//  BreakOut
//
//  Created by Leo Käßner on 14.08.15.
//  Copyright (c) 2015 BreakOut. All rights reserved.
//

import UIKit

// Analytics
import Fabric
import Crashlytics
import Flurry_iOS_SDK

import Firebase

import TouchVisualizer

// Database
import MagicalRecord
//import MagicalRecord

// Network Debugging
import netfox
import Sweeft

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FIRApp.configure()
        
        #if DEBUG
            //Instabug Setup
//            Instabug.start(withToken: PrivateConstants.instabugAPIToken, invocationEvent: IBGInvocationEvent.twoFingersSwipeLeft)
        #endif
        
        //Fabric Setup
        //Fabric.with([Crashlytics.self()])
        Fabric.with([Crashlytics.start(withAPIKey: PrivateConstants.crashlyticsAPIToken)])
        
        //Flurry Setup
        Flurry.startSession(PrivateConstants.flurryAPIToken);
        
        
        // Database
        MagicalRecord.setupCoreDataStack(withStoreNamed: "BODataModel")
        MagicalRecord.setLoggingLevel(MagicalRecordLoggingLevel.all) //All Events are logged to the console
        
        // Network Debugging
        #if DEBUG
            NFX.sharedInstance().start()
            Visualizer.start()
            
            NotificationCenter.default.addObserver(forName: nil,
                object: nil,
                queue: nil) {
                    note in
//                    if note.name.containsString("BONotification_") {
//                        print("Notification: " + note.name + "\r\n")
//                    }
            }
            
        #endif

        //BONetworkerTest().postObjectFromJSON()
        BOSynchronizeController.shared.checkForInternetReachability()
        
        //TESTING persistence of not yet loaded postings IDs
        //BOSynchronizeController.shared.downloadAllPostings()
        //BOSynchronizeController.shared.downloadNotYetLoadedPostings()
        //BOSynchronizeController.shared.downloadArrayOfNewPostingIDsSinceLastKnownPostingID()
        //BOSynchronizeController.shared.downloadIdsOfAllEvents()
        //BOSynchronizeController.shared.downloadChallengesForCurrentUser()
        
        BOLocationManager.shared.start()
        
        FeatureFlagManager.shared.downloadCurrentFeatureFlagSetup()
        
        let settings = UIApplication.shared.currentUserNotificationSettings
        
        if settings!.types == UIUserNotificationType() {
            let notificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(notificationSettings)
        }else{
            BOPushManager.shared.setupAllLocalPushNotifications()
        }
        
        if (launchOptions?[UIApplicationLaunchOptionsKey.location] as? NSDictionary) != nil {
            BOLocationManager.shared.start()
        }
        
        if (launchOptions?[UIApplicationLaunchOptionsKey.localNotification] as? NSDictionary) != nil {
            Answers.logCustomEvent(withName: "/Delegate/didLaunch/LocalNotificationKey", customAttributes: [:])
        }
        
        return true
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        BOLocationManager.shared.enterBackground()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        BOLocationManager.shared.becomeActive()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        // Database
        MagicalRecord.cleanUp()
    }


}

