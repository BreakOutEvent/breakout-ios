//
//  BackendServices.swift
//  BreakOut
//
//  Created by Mathias Quintero on 5/3/16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import Foundation
enum BackendServices: String {
    case User = "user/"
    case UserData = "user/%i/"
    case CurrentUser = "me/"
    case PostingsSince = "posting/get/since/%i/"
    case Postings = "posting"
    case NotLoadedPostings = "posting/get/ids"
    case EventInvitation = "event/%i/team/%i/invitation"
    case EventTeam = "event/%i/team/"
    case Event = "event/"
}