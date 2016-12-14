//
//  BOPost.swift
//  BreakOut
//
//  Created by Leo Käßner on 28.11.15.
//  Copyright © 2015 BreakOut. All rights reserved.
//

import Foundation
import SwiftyJSON
import Sweeft

// Tracking
import Flurry_iOS_SDK

final class BOPost {
    
    static var items = [Int : BOPost]()
    
    var uuid: Int
    var text: String?
    var city: String?
    var date: Date
    var longitude: Double
    var latitude: Double
    var flagNeedsUpload: Bool
    var flagNeedsDownload: Bool
    var team: BOTeam?
    var challenge: BOChallenge?
    var images: [BOMedia]
    var comments: [BOComment]
    var country: String?
    var locality: String?
    
    init(_ uuid: Int, flagNeedsDownload: Bool? = nil, date: Date = Date(), location: (Double, Double)) {
        self.uuid = uuid
        self.flagNeedsDownload = flagNeedsDownload ?? false
        latitude = location.0
        longitude = location.1
        flagNeedsUpload = !(flagNeedsDownload.?)
        self.date = date
        images = []
        comments = []
    }
    
    required convenience init?(from json: JSON) {
        guard let id = json["id"].int,
            let date = json["date"].date,
            let longitude = json["postingLocation"]["longitude"].double,
            let latitude = json["postingLocation"]["latitude"].double else {
                return nil
        }
        self.init(id, flagNeedsDownload: json["flagNeedsDownload"].bool, date: date, location: (latitude, longitude))
        self.setAttributes(from: json)
    }
    
    func addTeamWithId(_ teamId: Int) {
        let teamArray = BOTeam.all() { $0.uuid == teamId }
        if let team = teamArray.first {
            self.team = team
        }
    }
    
    func printToLog() {
        print("----------- BOPost -----------")
        print("ID: ", self.uuid)
        print("Text: ", self.text)
        print("Date: ", self.date.description)
        print("longitude: ", self.longitude)
        print("latitude: ", self.latitude)
        print("locality: ", self.locality)
        print("country: ", self.country)
        print("city: ", self.city)
        print("flagNeedsUpload: ", self.flagNeedsUpload)
        print("flagNeedsDownload: ", self.flagNeedsDownload)
        print("----------- ------ -----------")
    }
    
    func reload(_ handler: (() -> ())? = nil) {
        if BOSynchronizeController.shared.hasWifi {
            BONetworkManager.get(.PostingByID, arguments: [uuid], parameters: nil, auth: false, success: { (response: JSON) in
                response | self.setAttributes
                handler?()
            })
        }
    }
    
    func upload() {
        let dict = json
        
//        dict["text"] = text as AnyObject?;
//        dict["date"] = date.timeIntervalSince1970 as AnyObject?
//
//        var postingLocation = [String:AnyObject]()
//        postingLocation["latitude"] = latitude
//        postingLocation["longitude"] = longitude
//        
//        dict["postingLocation"] = postingLocation as AnyObject?
//        
        let img = images.map() { $0 as BOMedia }
//
//        dict["uploadMediaTypes"] = img.map() { $0.type } as AnyObject

        BONetworkManager.post(.Postings, arguments: [], parameters: dict, auth: true, success: { (json) in
            
            if let id = json["id"].int, let mediaArray = json["media"].array {
                self.uuid = id
                if !mediaArray.isEmpty {
                    for i in 0...(mediaArray.count-1) {
                        let respondedMediaItem = mediaArray[i]
                        let mediaItem = img[i]
                        if let id = respondedMediaItem["id"].int, let token = respondedMediaItem["uploadToken"].string {
                            mediaItem.uploadWithToken(id, token: token)
                        }
                    }
                }
                
                if self.challenge != nil {
                    self.challenge?.postingId = self.uuid
                    self.challenge?.status = "with_proof"
                    self.challenge?.flagNeedsUpload = true
                    
                    self.challenge?.upload()
                }
            }
            
            self.reload()
            // Tracking
            self.flagNeedsUpload = false
            self.save()
            Flurry.logEvent("/posting/upload/completed_successful")
        }) { (error, response) in
            // Tracking
            Flurry.logEvent("/posting/upload/completed_error")
        }
    }
    
    func setAttributes(from json: JSON) {
        flagNeedsUpload = json["flagNeedsUpload"].bool.?
        text = json["text"].string
        json["user"]["participant"]["teamId"].int | addTeamWithId
        country = json["postingLocation"]["locationData"]["COUNTRY"].string
        locality = json["postingLocation"]["locationData"]["LOCALITY"].string
        comments <- json["comments"].comments
        images <- json["images"].mediaStuffs
    }
    
}

extension BOPost: BOObject {
    
    var json: JSON {
        return JSON([:])
    }
    
}

extension JSON {
    
    var post: BOPost? {
        return BOPost.create(from: self)
    }
    
    var posts: [BOPost]? {
        return BOPost.array(from: self)
    }
    
}
