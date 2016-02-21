//
//  CurrentUser.swift
//  BreakOut
//
//  Created by Leo Käßner on 10.01.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit

import AFOAuth2Manager

class CurrentUser: NSObject {
    var userid: NSInteger?
    var firstname: String?
    var lastname: String?
    var email: String?
    var picture: UIImage?
    
    var gender: String? // "male"=0 or "female"=1
    var birthday: NSDate?
    var emergencyNumber: String?
    var phoneNumber: String?
    var shirtSize: String?
    var hometown: String?
    
    static let sharedInstance = CurrentUser()
    
    override init() {
        super.init()
        
        self.retrieveFromNSUserDefaults()
    }
    
// MARK: - Sync with Backend
    
    func uploadUserDataToBackend() {
        let requestManager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager.init(baseURL: NSURL(string: PrivateConstants.backendURL))
        
        let params: NSDictionary = self.attributesAsDictionary()
        
        requestManager.requestSerializer = AFJSONRequestSerializer()
        
        requestManager.requestSerializer.setAuthorizationHeaderFieldWithCredential( AFOAuthCredential.retrieveCredentialWithIdentifier("apiCredentials") )
        
        requestManager.PUT(String(format:"user/%i/",self.userid!), parameters: params, success: { (operation: AFHTTPRequestOperation, response: AnyObject) -> Void in
            // Successful
            BOToast(text: "SUCCESSFUL: uploaded CurrentUser info")
            }) { (operation: AFHTTPRequestOperation?, error: NSError) -> Void in
                // Error
                print("ERROR: During CurrentUser upload")
                print(error)
                BOToast(text: "ERROR: During CurrentUser upload")
        }
    }
    
    
// MARK: - Storing & Retrieving
    
    func attributesAsDictionary() -> NSMutableDictionary {
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
        
        //Event Infos
        if self.gender != nil {
            selfDictionary.setValue(self.gender, forKey: "gender")
        }
        if self.birthday != nil {
            selfDictionary.setValue(self.birthday, forKey: "birthday")
        }
        if self.phoneNumber != nil {
            selfDictionary.setValue(self.phoneNumber, forKey: "phoneNumber")
        }
        if self.emergencyNumber != nil {
            selfDictionary.setValue(self.emergencyNumber, forKey: "emergencyNumber")
        }
        if self.shirtSize != nil {
            selfDictionary.setValue(self.shirtSize, forKey: "shirtSize")
        }
        if self.hometown != nil {
            selfDictionary.setValue(self.hometown, forKey: "hometown")
        }
        
        return selfDictionary
    }
    
    func storeInNSUserDefaults() {
        //Write login data in UserDefaults
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let selfDictionary: NSMutableDictionary = self.attributesAsDictionary()
        
        //Store the user image
        if self.picture != nil {
            let imageData = UIImageJPEGRepresentation(self.picture!, 1)
            let relativePath = "image_\(NSDate.timeIntervalSinceReferenceDate()).jpg"
            let path = self.documentsPathForFileName(relativePath)
            imageData!.writeToFile(path, atomically: true)
        
            selfDictionary.setValue(relativePath, forKey: "picture")
        }
        
        
        defaults.setObject(selfDictionary, forKey: "userDictionary")
        defaults.synchronize()
        
        self.uploadUserDataToBackend()
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
                if keyName == "id" {
                    self.userid = keyValue as? NSInteger
                }else if keyName == "userid" {
                    self.userid = keyValue as? NSInteger
                }else if keyName == "firstname" {
                    self.firstname = keyValue as? String
                }else if keyName == "lastname" {
                    self.lastname = keyValue as? String
                }else if keyName == "email" {
                    self.email = keyValue as? String
                }else if keyName == "hometown" {
                    self.hometown = keyValue as? String
                }else if keyName == "gender" {
                    self.gender = keyValue as? String
                }else if keyName == "birthday" {
                    self.birthday = keyValue as? NSDate
                }else if keyName == "shirtSize" {
                    self.shirtSize = keyValue as? String
                }else if keyName == "emergencyNumber" {
                    self.emergencyNumber = keyValue as? String
                }else if keyName == "phoneNumber" {
                    self.phoneNumber = keyValue as? String
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
    
// MARK: - Return Value Helpers
    
    func username() -> String {
        var username = ""
        if self.firstname != nil {
            username.appendContentsOf(self.firstname!)
        }
        if self.lastname != nil {
            username.appendContentsOf(self.lastname!)
        }
        
        return username
    }
    
    func genderAsInt() -> Int {
        if self.gender == "male" {
            return 0
        }else if self.gender == "female"{
            return 1
        }else{
            return -1
        }
    }
    
    func setGenderFromInt(int: Int) {
        if int == 0 {
            self.gender = "male"
        }else if int == 1 {
            self.gender = "female"
        }else{
            self.gender = "unknown"
        }
    }
    

// MARK: - Image Storing Helpers
    
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
