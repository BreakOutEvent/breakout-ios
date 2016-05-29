//
//  BOPushManager.swift
//  BreakOut
//
//  Created by Leo Käßner on 29.05.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit

// Tracking
import Flurry_iOS_SDK
import Crashlytics

class BOPushManager: NSObject {
    
    static let sharedInstance = BOPushManager()
    
    var eventStartDate: NSDate?
    
    let oneHour: Double = 3600
    let oneDay: Double = 14400
    
    func setupAllLocalPushNotifications() {
        self.removeAllRegisteredNotifications()
        
        // Do any additional setup after loading the view.
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.objectForKey("eventStartTimestamp") != nil {
            self.eventStartDate = NSDate(timeIntervalSince1970: (defaults.objectForKey("eventStartTimestamp") as! Double))
        }
        
        print("BOPushManager: EventStartDate: ", self.eventStartDate?.description)
        if self.eventStartDate != nil {
            self.registerPush((eventStartDate?.dateByAddingTimeInterval(-self.oneDay))!, text: NSLocalizedString("Push_24h_before_Start", comment: "push"))
            
            self.registerPush((eventStartDate?.dateByAddingTimeInterval(-self.oneHour))!, text: NSLocalizedString("Push_1h_before_Start", comment: "push"))
            
            self.registerPush((eventStartDate?.dateByAddingTimeInterval(self.oneHour))!, text: NSLocalizedString("Push_1h_after_Start", comment: "push"))
            
            self.registerPush((eventStartDate?.dateByAddingTimeInterval(18*self.oneHour))!, text: NSLocalizedString("Push_18h_after_Start", comment: "push"))
            
            self.registerPush((eventStartDate?.dateByAddingTimeInterval(35*self.oneHour))!, text: NSLocalizedString("Push_35h_after_Start", comment: "push"))
            
            self.registerPush((eventStartDate?.dateByAddingTimeInterval(2*self.oneDay))!, text: NSLocalizedString("Push_2d_after_Start", comment: "push"))
            
            self.registerPush((eventStartDate?.dateByAddingTimeInterval(7*self.oneDay))!, text: NSLocalizedString("Push_7d_after_Start", comment: "push"))
            
            if defaults.objectForKey("lastPostingSent") != nil {
                let lastPostingSentDate: NSDate = defaults.objectForKey("lastPostingSent") as! NSDate
                
                self.registerPush(lastPostingSentDate.dateByAddingTimeInterval(self.oneHour), text: NSLocalizedString("Push_1h_after_last_Posting", comment: "push"))
            }
        }
    }

    func removeAllRegisteredNotifications() {
        UIApplication.sharedApplication().scheduledLocalNotifications?.removeAll()
    }
    
    func registerPush(fireDate: NSDate, text: String) {
        let notification = UILocalNotification()
        notification.fireDate = fireDate
        notification.alertBody = text
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
}
