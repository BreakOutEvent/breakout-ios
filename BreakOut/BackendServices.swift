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
    case Postings = "posting/"
    case PostingsOffsetLimit = "posting/?offset=%i&limit=%i"
    case PostComment = "posting/%i/comment/"
    case PostingIdsForTeam = "event/%i/team/%i/posting/"
    case NotLoadedPostings = "posting/get/ids/"
    case EventInvitation = "event/%i/team/%i/invitation/"
    case EventTeam = "event/%i/team/"
    case EventAllLocations = "event/%i/location/"
    case Event = "event/"
    case EventTeamLocation = "event/%i/team/%i/location/"
    case FeatureFlags = "featureFlags/"
    case PostingByID = "posting/%i/"
    case EventTeamChallenge = "event/%i/team/%i/challenge/"
    case ChallengeStatus = "event/%i/team/%i/challenge/%i/status/"
    case EventLocationsSince = "event/%i/location/since/%i/"
}
