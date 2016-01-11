//
//  CurrentUser.swift
//  BreakOut
//
//  Created by Leo Käßner on 10.01.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit

class CurrentUser: NSObject {
    var userID: Int?
    var firstname: String?
    var lastname: String?
    var email: String?
    var hometown: String?
    
    static let sharedInstance = CurrentUser()
    
    func storeInNSUserDefaults() {
        //Write login data in UserDefaults
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let selfDictionary: NSMutableDictionary = NSMutableDictionary()
        if self.userID != nil {
            selfDictionary.setValue(self.userID, forKey: "userID")
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
        
        
        defaults.setObject(selfDictionary, forKey: "userDictionary")
        defaults.synchronize()
    }
    
    func retrieveFromNSUserDefaults() {
        //Write login data in UserDefaults
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.objectForKey("userDictionary") != nil {
            let selfDictionary:NSDictionary = defaults.objectForKey("userDictionary") as! NSDictionary
            self.setAttributesWithJSON(selfDictionary)
        }
    }
    
    override init() {
        super.init()
        
        self.retrieveFromNSUserDefaults()
    }
    
    
    func setAttributesWithJSONString(JSONString: String) {
        
        let JSONData = JSONString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        var jsonDictionary: NSDictionary = NSDictionary()
        do {
            jsonDictionary = try NSJSONSerialization.JSONObjectWithData(JSONData!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
        }catch let error as NSError{
            print(error.localizedDescription)
        }
        
        self.setAttributesWithJSON(jsonDictionary)
    }
    
    func setAttributesWithJSON(jsonDictionary: NSDictionary) {
        // Loop
        for (key, value) in jsonDictionary {
            if value.isKindOfClass(NSNull) == false {
                let keyName = key as! String
                let keyValue = value
            
                // If property exists
                if (self.respondsToSelector(NSSelectorFromString(keyName))) {
                    self.setValue(keyValue, forKey: keyName)
                }
            }
        }
        
        self.storeInNSUserDefaults()
        // Or you can do it with using
        // self.setValuesForKeysWithDictionary(JSONDictionary)
        // instead of loop method above
    }
}
