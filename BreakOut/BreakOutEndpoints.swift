//
//  BreakOutEndpoints.swift
//  BreakOut
//
//  Created by Mathias Quintero on 2/25/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import Sweeft

/// Endpoint provided by the BreakOut Backend
enum BreakOutEndpoint: String, APIEndpoint {
    case user = "user/"
    case userData = "user/{id}/"
    case currentUser = "me/"
    case postingsSince = "posting/get/since/{id}/"
    case postings = "posting/"
    case postComment = "posting/{id}/comment/"
    case postingIdsForTeam = "event/{event}/team/{team}/posting/"
    case postingsForHashtag = "/posting/hashtag/{hashtag}/"
    case likePosting = "/posting/{id}/like/"
    case notLoadedPostings = "posting/get/ids/"
    case eventInvitation = "event/{event}/team/{id}/invitation/"
    case eventTeam = "event/{event}/team/"
    case eventAllLocations = "event/{event}/location/"
    case event = "event/"
    case eventTeamLocation = "event/{event}/team/{team}/location/"
    case featureFlags = "featureFlags/"
    case postingByID = "posting/{id}/"
    case teamByID = "event/{event}/team/{id}/"
    case eventTeamChallenge = "event/{event}/team/{team}/challenge/"
    case challengeStatus = "event/{event}/team/{team}/challenge/{challenge}/status/"
    case login = "oauth/token"
}
