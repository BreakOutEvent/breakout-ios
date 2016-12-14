//
//  BOComment.swift
//  BreakOut
//
//  Created by Mathias Quintero on 5/21/16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import SwiftyJSON
import Sweeft

// Tracking
import Flurry_iOS_SDK

final class BOComment {
    
    static var items = [Int : BOComment]()
    
    var uuid: Int
    var postID: Int?
    var text: String?
    var name: String?
    var date: Date
    var flagNeedsUpload: Bool
    var profilePic: BOMedia?
    
    init(uuid: Int, postID: Int? = nil, flagNeedsUpload: Bool = true, date: Date = Date(), text: String? = nil, name: String? = nil, profilePic: BOMedia? = nil) {
        self.uuid = uuid
        self.postID = postID
        self.flagNeedsUpload = flagNeedsUpload
        self.text = text
        self.name = name
        self.profilePic = profilePic
        self.date = date
    }
    
    required convenience init?(from json: JSON) {
        guard let id = json["id"].int,
            let date = json["date"].date else {
                return nil
        }
        let flagNeedsUpload = json["flagNeedsUpload"].bool.?
        let text = json["text"].string
        let name: String?
        if let first = json["user"]["firstname"].string, let last = json["user"]["lastname"].string {
            name = first + " " + last
        } else {
            name = nil
        }
        let profilePic = json["profilePic"].media
        self.init(uuid: id, flagNeedsUpload: flagNeedsUpload, date: date, text: text, name: name, profilePic: profilePic)
    }
    
    func upload() {
        var dict = [String:AnyObject]()
        dict["text"] = self.text as AnyObject?
        dict["date"] = date.timeIntervalSince1970 as AnyObject?
        BONetworkManager.post(.PostComment, arguments: ![postID], parameters: dict, auth: true, success: { (response) in
            // Tracking
            self.flagNeedsUpload = false
//            self.save()
            Flurry.logEvent("/posting/comment/upload/completed_successful")
        }) { (error, response) in
            Flurry.logEvent("/posting/comment/upload/completed_error")
        }
    }
    
    func printToLog() {
        print("----------- BOComment -----------")
        print("ID: ", self.uuid)
        print("Text: ", self.text)
        print("----------- ------ -----------")
    }

}

extension BOComment: BOObject {
    
    var json: JSON {
        return JSON([:])
    }
    
}

extension JSON {
    
    var comment: BOComment? {
        return BOComment.create(from: self)
    }
    
    var comments: [BOComment]? {
        return BOComment.array(from: self)
    }
    
}
