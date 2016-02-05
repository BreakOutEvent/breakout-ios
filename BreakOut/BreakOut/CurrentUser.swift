//
//  CurrentUser.swift
//  BreakOut
//
//  Created by Leo Käßner on 10.01.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit

class CurrentUser: NSObject {
    var userid: NSInteger?
    var firstname: String?
    var lastname: String?
    var email: String?
    var hometown: String?
    var picture: UIImage?
    
    static let sharedInstance = CurrentUser()
    
    override init() {
        super.init()
        
        self.retrieveFromNSUserDefaults()
    }
    
    
// MARK: - Storing & Retrieving
    
    func storeInNSUserDefaults() {
        //Write login data in UserDefaults
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let selfDictionary: NSMutableDictionary = NSMutableDictionary()
        if self.userid != nil {
            selfDictionary.setObject(self.userid!, forKey: "userid")
        }
        if self.firstname != nil {
            selfDictionary.setValue(self.firstname, forKey: "firstname")
        }
        if self.lastname != nil {
            selfDictionary.setValue(self.lastname, forKey: "lastname")
        }
        if self.email != nil {
            selfDictionary.setValue(self.email, forKey: "email")
        }
        if self.hometown != nil {
            selfDictionary.setValue(self.hometown, forKey: "hometown")
        }
        
        //Store the user image
        let imageData = UIImageJPEGRepresentation(self.picture!, 1)
        let relativePath = "image_\(NSDate.timeIntervalSinceReferenceDate()).jpg"
        let path = self.documentsPathForFileName(relativePath)
        imageData!.writeToFile(path, atomically: true)
        
        if self.picture != nil {
            selfDictionary.setValue(relativePath, forKey: "picture")
        }
        
        
        defaults.setObject(selfDictionary, forKey: "userDictionary")
        defaults.synchronize()
    }
    
    func retrieveFromNSUserDefaults() {
        //Write login data in UserDefaults
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.objectForKey("userDictionary") != nil {
            let selfDictionary:NSDictionary = defaults.objectForKey("userDictionary") as! NSDictionary
            self.setAttributesWithJSON(selfDictionary)
            //self.setValuesForKeysWithDictionary(selfDictionary as! [String : AnyObject])
        }
    }
    
    func setAttributesWithJSON(jsonDictionary: NSDictionary) {
        for (key, value) in jsonDictionary {
            if value.isKindOfClass(NSNull) == false {
                let keyName = key as! String
                let keyValue = value
                
                // If property exists
                if keyName == "userid" {
                    self.userid = keyValue as? NSInteger
                }else if keyName == "firstname" {
                    self.firstname = keyValue as? String
                }else if keyName == "lastname" {
                    self.lastname = keyValue as? String
                }else if keyName == "email" {
                    self.email = keyValue as? String
                }else if keyName == "hometown" {
                    self.hometown = keyValue as? String
                }else if keyName == "picture" {
                    let imageFullPath = self.documentsPathForFileName(keyValue as! String)
                    let userImageData = NSData(contentsOfFile: imageFullPath)
                    // here is your saved image:
                    if userImageData != nil {
                        self.picture = UIImage(data: userImageData!)
                    }
                }
            }
        }
    }
    
    func getDocumentsURL() -> NSURL {
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        return documentsURL
    }
    
    func fileInDocumentsDirectory(filename: String) -> String {
        
        let fileURL = getDocumentsURL().URLByAppendingPathComponent(filename)
        return fileURL.path!
        
    }
    
    func documentsPathForFileName(name: String) -> String {
        return fileInDocumentsDirectory(name)

    }
}
