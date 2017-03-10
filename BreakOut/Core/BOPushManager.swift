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
    
    static let shared = BOPushManager()
    
    var eventStartDate: Date?
    
    let oneHour: Double = 3600
    let oneDay: Double = 14400
    
    func setupAllLocalPushNotifications() {
        self.removeAllRegisteredNotifications()
        
        // Do any additional setup after loading the view.
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "eventStartTimestamp") != nil {
            self.eventStartDate = Date(timeIntervalSince1970: (defaults.object(forKey: "eventStartTimestamp") as! Double))
        }
        
        print("BOPushManager: EventStartDate: ", self.eventStartDate?.description)
        if self.eventStartDate != nil {
            self.registerPush((eventStartDate?.addingTimeInterval(-self.oneDay))!, text: "Push_24h_before_Start".localized(with: "push"))
            
            self.registerPush((eventStartDate?.addingTimeInterval(-self.oneHour))!, text: "Push_1h_before_Start".localized(with: "push"))
            
            self.registerPush((eventStartDate?.addingTimeInterval(self.oneHour))!, text: "Push_1h_after_Start".localized(with: "push"))
            
            self.registerPush((eventStartDate?.addingTimeInterval(18*self.oneHour))!, text: "Push_18h_after_Start".localized(with: "push"))
            
            self.registerPush((eventStartDate?.addingTimeInterval(35*self.oneHour))!, text: "Push_35h_after_Start".localized(with: "push"))
            
            self.registerPush((eventStartDate?.addingTimeInterval(2*self.oneDay))!, text: "Push_2d_after_Start".localized(with: "push"))
            
            self.registerPush((eventStartDate?.addingTimeInterval(7*self.oneDay))!, text: "Push_7d_after_Start".localized(with: "push"))
            
            if defaults.object(forKey: "lastPostingSent") != nil {
                let lastPostingSentDate: Date = defaults.object(forKey: "lastPostingSent") as! Date
                
                self.registerPush(lastPostingSentDate.addingTimeInterval(self.oneHour), text: "Push_1h_after_last_Posting".localized(with: "push"))
            }
        }
    }

    func removeAllRegisteredNotifications() {
        UIApplication.shared.scheduledLocalNotifications?.removeAll()
    }
    
    func registerPush(_ fireDate: Date, text: String) {
        let notification = UILocalNotification()
        notification.fireDate = fireDate
        notification.alertBody = text
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.shared.scheduleLocalNotification(notification)
    }
}
