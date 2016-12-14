//
//  BOTeam.swift
//  BreakOut
//
//  Created by Mathias Quintero on 5/21/16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import SwiftyJSON
import Sweeft

// Tracking
import Flurry_iOS_SDK

final class BOTeam {
    
    static var items = [Int : BOTeam]()
    
    var uuid: Int
    var text: String?
    var flagNeedsDownload: Bool
    var name: String?
    var profilePic: BOMedia?
    
    init(uuid: Int, flagNeedsDownload: Bool = false, name: String? = nil, profilePic: BOMedia? = nil, text: String? = nil) {
        self.uuid = uuid
        self.flagNeedsDownload = flagNeedsDownload
        self.name = name
        self.profilePic = profilePic
        self.text = text
    }
    
    required convenience init?(from json: JSON) {
        guard let id = json["id"].int else {
            return nil
        }
        let flagNeedsDownload = json["flagNeedsDownload"].bool ?? false
        let name = json["name"].string
        let profilePic = json["profilePic"].media
        let text = json["text"].string
        self.init(uuid: id, flagNeedsDownload: flagNeedsDownload, name: name, profilePic: profilePic, text: text)
    }
    
    func printToLog() {
        print("----------- BOTeam -----------")
        print("ID: ", self.uuid)
        print("Text: ", self.text)
        print("flagNeedsDownload: ", self.flagNeedsDownload)
        print("----------- ------ -----------")
    }
}

extension BOTeam: BOObject {
    
    var json: JSON {
        return JSON([:])
    }
    
}

extension JSON {
    
    var team: BOTeam? {
        return BOTeam.create(from: self)
    }
    
    var teams: [BOTeam]? {
        return BOTeam.array(from: self)
    }
    
}
