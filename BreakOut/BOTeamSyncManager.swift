//
//  BOTeamSyncManager.swift
//  BreakOut
//
//  Created by Mathias Quintero on 9/26/16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import Foundation
import Sweeft
import Flurry_iOS_SDK

class BOTeamSyncManager: BOSyncManager {
    
    required init() { }
    
    func uploadMissing() { }
    
    func dowloadMisisng() { }
    
    
    // MARK: Team List
    /**
     Get total list of all teams and store response in Database.
     */
    func loadTotalTeamList() {
        
    }
    
    /**
     Get only updates of the team list till specified date and store response in Database.
     */
    func loadUpdatesOfTeamList(_ date: Date) {
        
    }
    
    /**
     calculates the last update of the team list and loads new team list updates since then. It uses the `loadUpdatesOfTeamList` Function.
     */
    func loadUpdatesOfTeamListSinceLastUpdate() {
        
    }
    
    func downloadChallengesForCurrentUser() {
        if CurrentUser.shared.isLoggedIn() && CurrentUser.shared.currentTeamId() >= 0 && CurrentUser.shared.currentEventId() >= 0 {
            self.downloadChallengesForTeam(CurrentUser.shared.currentTeamId(), eventId: CurrentUser.shared.currentEventId())
        }
    }
    
    func downloadChallengesForTeam(_ teamId: Int, eventId: Int) {
//        BONetworkManager.get(.EventTeamChallenge, arguments: [eventId, teamId], parameters: nil, auth: false, success: { (response) in
//            // response is an Array of Location Objects
//            for newChallenge: NSDictionary in response as! Array {
//                BOChallenge.createWithDictionary(newChallenge)
//            }
//            //BOToast.log("Downloading all postings was successful \(numberOfAddedPosts)")
//            // Tracking
//            //Flurry.logEvent("/posting/download/completed_successful", withParameters: ["API-Path":"GET: posting/", "Number of downloaded Postings":numberOfAddedPosts])
//        }) { (error, response) in
//            // TODO: Handle Errors
//            //Flurry.logEvent("/posting/download/completed_error", withParameters: ["API-Path":"GET: posting/"])
//        }
    }
    
    func getAllEvents() {
//        BONetworkManager.get(.Event, arguments: [], parameters: nil, auth: true, success: { (response) in
//            if let responseArray: Array = response as? Array<NSDictionary> {
//                var res = [BOEvent]()
//                for eventDictionary: NSDictionary in responseArray {
//                    let newEvent: BOEvent = BOEvent(id: (eventDictionary["id"] as? Int)!, title: (eventDictionary["title"] as? String)!, dateUnixTimestamp: (eventDictionary["date"] as? Int)!, city:(eventDictionary["city"] as? String)!)
//                    res.append(newEvent)
//                }
//                success(res)
//            } else {
//                success([])
//            }
//        }) { (error, response) in
//            if response?.statusCode == 401 {
//                NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION_PRESENT_LOGIN_SCREEN), object: nil)
//            }
//        }
    }
    
    func downloadAllTeamsForEvent(_ eventId: Int) {
//        BONetworkManager.get(.EventTeam, arguments: [eventId], parameters: nil, auth: false, success: { (response) in
//            var numberOfAddedTeams: Int = 0
//            // response is an Array of Team Objects
//            let arrayExistingTeams = BOTeam.all
//            for newTeam in response.array.? {
//                //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
//                let index = arrayExistingTeams.index(where: { $0.uuid == newTeam["id"].int.? })
//                if index != nil {
//                    // Team already exists
//                } else {
//                    _ = BOTeam(from: newTeam)
//                }
//                //})
//                //newPost.printToLog()
//                numberOfAddedTeams += 1
//            }
//            //BOToast.log("Downloading all postings was successful \(numberOfAddedPosts)")
//            // Tracking
//            //Flurry.logEvent("/posting/download/completed_successful", withParameters: ["API-Path":"GET: posting/", "Number of downloaded Postings":numberOfAddedPosts])
//        }) { (error, response) in
//            // TODO: Handle Errors
//            //Flurry.logEvent("/posting/download/completed_error", withParameters: ["API-Path":"GET: posting/"])
//        }
    }
    
    func createTeam(_ name: String, eventID: Int, image: UIImage?, success: @escaping () -> (), error: @escaping () -> ()) {
//        let params: NSDictionary = [
//            "event": eventID,
//            "name": name
//        ]
//        BONetworkManager.post(BackendServices.EventTeam, arguments: [eventID], parameters: params, auth: true, success: { (response) in
//            if let imageUnwrapped = image,
//                let token = response["profilePic"]["uploadToken"].string,
//                let id = response["profilePic"]["id"].int {
//                
//                let boImage = BOMedia(from: imageUnwrapped)
//                boImage.uploadWithToken(id, token: token)
//            }
//            
//            if let team = BOTeam(from: response) {
//                CurrentUser.shared.teamid = team.uuid
//                CurrentUser.shared.storeInNSUserDefaults()
//            }
//            success()
//        }) { (err, response) in
//            // TODO: Maybe show something more to the user
//            error()
//        }
    }
    
    func sendInvitationToTeam(_ teamID: Int, name: String, eventID: Int, handler: @escaping () -> ()) {
        
        //TODO: Which parameter need to be passed to the API-Endpoint?
        let params: NSDictionary = [
            "event": eventID,
            "name": name
        ]
        
        BONetworkManager.post(.EventInvitation, arguments: [eventID, teamID], parameters: params, auth: true, success: { (response) in
            CurrentUser.shared.setAttributesWithJSON(response as! NSDictionary)
            handler()
        }) { (_,_) in
            handler()
        }
    }
    
    func becomeParticipant(firstName: String, lastname: String, gender: String, email: String, emergencyNumber: String, phone: String, shirtSize: String, success: @escaping () -> (), error: @escaping () -> ()) {
        
        if let userID = CurrentUser.shared.userid {
            
            let participantParams: NSDictionary = [
                "emergencynumber": emergencyNumber,
                //"hometown": self.hometownTextfield.text!,
                //TODO: Birthday an Backend übertragen
                "phonenumber": phone,
                "tshirtsize": shirtSize
            ]
            let params: NSDictionary = [
                "firstname": firstName,
                "lastname": lastname,
                "email": email,
                "gender": gender,
                "participant": participantParams
            ]
            
            BONetworkManager.put(.UserData, arguments: [userID], parameters: params, auth: true, success: { (response) in
                CurrentUser.shared.setAttributesWithJSON(response as! NSDictionary)
                
                // Tracking
                Flurry.logEvent("/user/becomeParticipant/completed_successful")
                success()
            }) { (err, response) in
                
                // TODO: Show detailed errors to the user
                if response?.statusCode == 401 {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION_PRESENT_LOGIN_SCREEN), object: nil)
                }
                error()
                
            }
        }
        
    }
    
}
