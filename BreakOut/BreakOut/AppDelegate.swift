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

import TouchVisualizer

// Database
import MagicalRecord
//import MagicalRecord

// Network Debugging
import netfox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        #if DEBUG
            //Instabug Setup
            Instabug.startWithToken(PrivateConstants.instabugAPIToken, invocationEvent: IBGInvocationEvent.TwoFingersSwipeLeft)
        #endif
        
        //Fabric Setup
        //Fabric.with([Crashlytics.self()])
        Fabric.with([Crashlytics.startWithAPIKey(PrivateConstants.crashlyticsAPIToken)])
        
        //Flurry Setup
        Flurry.startSession(PrivateConstants.flurryAPIToken);
        
        
        // Database
        MagicalRecord.setupCoreDataStackWithStoreNamed("BODataModel")
        MagicalRecord.setLoggingLevel(MagicalRecordLoggingLevel.All) //All Events are logged to the console
        
        // Network Debugging
        #if DEBUG
            NFX.sharedInstance().start()
            Visualizer.start()
            
            NSNotificationCenter.defaultCenter().addObserverForName(nil,
                object: nil,
                queue: nil) {
                    note in
                    if note.name.containsString("BONotification_") {
                        print("Notification: " + note.name + "\r\n")
                    }
            }
            
            
            print("----------- DB Entity Counts ----------------------")
            print("BOPost: ", BOPost.MR_countOfEntities())
            print("BOLocation: ", BOLocation.MR_countOfEntities())
            print("BOImage: ", BOImage.MR_countOfEntities())
            print("BOTeam: ", BOTeam.MR_countOfEntities())
            print("BOChallenge: ", BOChallenge.MR_countOfEntities())
            print("BOComment: ", BOComment.MR_countOfEntities())
            print("---------------------------------------------------")
        #endif

        //BONetworkerTest().postObjectFromJSON()
        BOSynchronizeController.sharedInstance.checkForInternetReachability()
        
        //TESTING persistence of not yet loaded postings IDs
        //BOSynchronizeController.sharedInstance.downloadAllPostings()
        //BOSynchronizeController.sharedInstance.downloadNotYetLoadedPostings()
        BOSynchronizeController.sharedInstance.downloadArrayOfNewPostingIDsSinceLastKnownPostingID()
        BOSynchronizeController.sharedInstance.downloadIdsOfAllEvents()
        BOSynchronizeController.sharedInstance.downloadChallengesForCurrentUser()
        
        BOLocationManager.sharedInstance.start()
        
        FeatureFlagManager.sharedInstance.downloadCurrentFeatureFlagSetup()
        
        let settings = UIApplication.sharedApplication().currentUserNotificationSettings()
        
        if settings!.types == .None {
            let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        }else{
            BOPushManager.sharedInstance.setupAllLocalPushNotifications()
        }
        
        if (launchOptions?[UIApplicationLaunchOptionsLocationKey] as? NSDictionary) != nil {
            BOLocationManager.sharedInstance.start()
        }
        
        if (launchOptions?[UIApplicationLaunchOptionsLocalNotificationKey] as? NSDictionary) != nil {
            Answers.logCustomEventWithName("/Delegate/didLaunch/LocalNotificationKey", customAttributes: [:])
        }
        
        return true
    }
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        BOLocationManager.sharedInstance.enterBackground()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        BOLocationManager.sharedInstance.becomeActive()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        // Database
        MagicalRecord.cleanUp()
    }


}

