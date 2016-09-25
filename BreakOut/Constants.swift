//
//  Constants.swift
//  BreakOut
//
//  Created by Leo Käßner on 12.03.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import Foundation

struct Constants {
    static let NOTIFICATION_PRESENT_LOGIN_SCREEN: String = "BONotification_presentLoginScreen"
    static let NOTIFICATION_CURRENT_USER_UPDATED: String = "BONotification_notificationCurrentUserUpdated"
    static let NOTIFICATION_NEW_POSTING_CLOSED_WANTS_LIST: String = "BONotification_newPostingClosedAndWantsListOfAllPostings"
    static let NOTIFICATION_PRESENT_WELCOME_SCREEN: String = "BONotification_presentWelcomeScreen"
    
    // Locations
    static let NOTIFICATION_LOCATION_DID_UPDATE: String = "BONotification_locationDidUpdate"
    
    //Database
    static let NOTIFICATION_DB_BOPOST_DID_SAVE: String = "BONotification_dbBOPostDidSave"
}