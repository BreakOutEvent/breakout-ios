//
//  BOTeam.swift
//  BreakOut
//
//  Created by Mathias Quintero on 5/21/16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import Foundation

// Database
import MagicalRecord

// Tracking
import Flurry_iOS_SDK

@objc(BOTeam)
class BOTeam: NSManagedObject {
    
    @NSManaged var uuid: NSInteger
    @NSManaged var text: String?
    @NSManaged var flagNeedsDownload: Bool
    @NSManaged var name: String?
    @NSManaged var profilePic: BOImage?
    
    class func create(_ uuid: Int, flagNeedsDownload: Bool) -> BOTeam {
        if let origTeamArray = BOPost.mr_find(byAttribute: "uuid", withValue: uuid) as? Array<BOTeam>, let team = origTeamArray.first {
            team.flagNeedsDownload = false
            return team
        }
        
        let res = BOTeam.mr_createEntity()! as BOTeam
        res.uuid = uuid as NSInteger
        res.flagNeedsDownload = flagNeedsDownload
        
        // Save
        NSManagedObjectContext.mr_default().mr_saveToPersistentStore(completion: nil)
        return res;
    }
    
    class func createWithDictionary(_ dict: NSDictionary) -> BOTeam {
        let res: BOTeam
        if let id = dict["id"] as? NSInteger,
            let origTeamArray = BOTeam.mr_find(byAttribute: "uuid", withValue: id) as? Array<BOTeam>,
            let team = origTeamArray.first {
            res = team
        } else {
            res = BOTeam.mr_createEntity()!
        }
        
        res.setAttributesWithDictionary(dict)
        
        NSManagedObjectContext.mr_default().mr_saveToPersistentStore(completion: nil)
        
        return res
    }
    
    func setAttributesWithDictionary(_ dict: NSDictionary) {
        uuid = dict.value(forKey: "id") as! NSInteger
        text = dict.value(forKey: "description") as? String
        name = dict.value(forKey: "name") as? String
        if let profilePicDict = dict.value(forKey: "profilePic") as? NSDictionary {
            BOImage.createFromDictionary(profilePicDict) { (image) in
                self.profilePic = image
                self.save()
            }
        }
        self.save()
    }
    
    func save() {
        NSManagedObjectContext.mr_default().mr_saveToPersistentStore(completion: nil)
    }
    
    func printToLog() {
        print("----------- BOTeam -----------")
        print("ID: ", self.uuid)
        print("Text: ", self.text)
        print("flagNeedsDownload: ", self.flagNeedsDownload)
        print("----------- ------ -----------")
    }
}
