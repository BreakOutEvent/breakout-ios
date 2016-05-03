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
    let KEY_USERID: String = "userid"
    
    var firstname: String?
    
    var lastname: String?
    var email: String?
    var picture: UIImage?
    
    var gender: String? // "male"=0 or "female"=1
    var birthday: NSDate?
    
    var emergencyNumber: String?
    let KEY_EMERGENCYNUMBER: String = "emergencynumber"
    
    var phoneNumber: String?
    let KEY_PHONENUMBER: String = "phonenumber"
    
    var shirtSize: String?
    
    var hometown: String?
    
    var flagBlocked: Bool = false
    var flagParticipant: Bool = false
    
    static let sharedInstance = CurrentUser()
    
    override private init() {
        super.init()
        
        self.retrieveFromNSUserDefaults()
    }
    
    func presentLoginScreenFromViewController(fromView: UIViewController) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginRegisterViewController: LoginRegisterViewController = storyboard.instantiateViewControllerWithIdentifier("LoginRegisterViewController") as! LoginRegisterViewController
        
        fromView.presentViewController(loginRegisterViewController, animated: true, completion: nil)
    }
    
// MARK: - Sync with Backend
    
    func uploadUserDataToBackend() {
        
        let params: NSMutableDictionary = self.attributesAsDictionary()
        
        params.setValue(self.attributesAsDictionary(), forKey: "participant")
        
        BONetworkIndicator.si.increaseLoading()
        
        BONetworkManager.doJSONRequestPUT(.UserData, arguments: [self.userid!], parameters: params, auth: true) { (response) in
            BONetworkIndicator.si.decreaseLoading()
        }
        
        
//        let requestManager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager.init(baseURL: NSURL(string: PrivateConstants.backendURL))
//        
//        let params: NSMutableDictionary = self.attributesAsDictionary()
//        
//        // Restructure the params Array
//        params.setValue(self.attributesAsDictionary(), forKey: "participant")
//        
//        
//        requestManager.requestSerializer = AFJSONRequestSerializer()
//        
//        requestManager.requestSerializer.setAuthorizationHeaderFieldWithCredential( AFOAuthCredential.retrieveCredentialWithIdentifier("apiCredentials") )
//        
//        BONetworkIndicator.si.increaseLoading()
//        requestManager.PUT(String(format:"user/%i/",self.userid!), parameters: params, success: { (operation: AFHTTPRequestOperation, response: AnyObject) -> Void in
//            BONetworkIndicator.si.decreaseLoading()
//            // Successful
//            BOToast.log("Successfully uploaded currentUser info")
//            }) { (operation: AFHTTPRequestOperation?, error: NSError) -> Void in
//                BONetworkIndicator.si.decreaseLoading()
//                // Error
//                
//                if operation?.response?.statusCode == 401 {
//                    NSNotificationCenter.defaultCenter().postNotificationName(Constants.NOTIFICATION_PRESENT_LOGIN_SCREEN, object: nil)
//                }
//                
//                print("ERROR: During CurrentUser upload")
//                print(error)
//                BOToast.log("Error during CurrentUser upload", level: .Error)
//        }
    }
    
    func downloadUserData() {
        
        BONetworkIndicator.si.increaseLoading()
        
        BONetworkManager.doJSONRequestGET(.CurrentUser, arguments: [], parameters: nil, auth: true) { (response) in
            // Successful
            BONetworkIndicator.si.decreaseLoading()

            let basicUserDict: NSDictionary = response as! NSDictionary
            
            print("---------------------------------")
            print("CurrentUser: ")
            print(basicUserDict)
            print("---------------------------------")
            
            self.setAttributesWithJSON(basicUserDict)
            
            // If the user is also an participant we should store the participants information
            if (basicUserDict.objectForKey("participant") != nil) {
                if let participantDictionary: NSDictionary = basicUserDict.valueForKey("participant") as? NSDictionary {
                    self.setAttributesWithJSON(participantDictionary)
                    // Participant Information is connected to the user -> Mark him as Participant
                    self.flagParticipant = true
                }else{
                    // No participant Information is connected to the user -> Mark him as NO Participant
                    self.flagParticipant = false
                }
            }else{
                // No participant Information is connected to the user -> Mark him as NO Participant
                self.flagParticipant = false
            }
            self.storeInNSUserDefaults()
        }
    }
    
    
// MARK: - Storing & Retrieving
    
    func attributesAsDictionary() -> NSMutableDictionary {
        let selfDictionary: NSMutableDictionary = NSMutableDictionary()
        if self.userid != nil {
            selfDictionary.setObject(self.userid!, forKey: KEY_USERID)
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
            selfDictionary.setValue(self.phoneNumber, forKey: KEY_PHONENUMBER)
        }
        if self.emergencyNumber != nil {
            selfDictionary.setValue(self.emergencyNumber, forKey: KEY_EMERGENCYNUMBER)
        }
        if self.shirtSize != nil {
            selfDictionary.setValue(self.shirtSize, forKey: "shirtSize")
        }
        if self.hometown != nil {
            selfDictionary.setValue(self.hometown, forKey: "hometown")
        }
        
        selfDictionary.setValue(self.flagParticipant, forKey: "flagParticipant")
        selfDictionary.setValue(self.flagBlocked, forKey: "flagBlocked")
        
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
                }else if keyName == KEY_USERID {
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
                }else if keyName == "tshirtsize" {
                    self.shirtSize = keyValue as? String
                }else if keyName == "emergencynumber" {
                    self.emergencyNumber = keyValue as? String
                }else if keyName == KEY_PHONENUMBER {
                    self.phoneNumber = keyValue as? String
                }else if keyName == "picture" {
                    let imageFullPath = self.documentsPathForFileName(keyValue as! String)
                    let userImageData = NSData(contentsOfFile: imageFullPath)
                    // here is your saved image:
                    if userImageData != nil {
                        self.picture = UIImage(data: userImageData!)
                    }
                }else if keyName == "flagBlocked" {
                    self.flagBlocked = (keyValue as? Bool)!
                }else if keyName == "flagParticipant" {
                    self.flagParticipant = (keyValue as? Bool)!
                }
            }
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.NOTIFICATION_CURRENT_USER_UPDATED, object: nil)
    }
    
// MARK: - Return Value Helpers
    
    func username() -> String {
        var username = ""
        if self.firstname != nil {
            username.appendContentsOf(self.firstname!)
            username.appendContentsOf(" ")
        }
        if self.lastname != nil {
            username.appendContentsOf(self.lastname!)
        }
        
        if username == "" || username == " " {
            if self.email != nil {
                username = (self.email?.componentsSeparatedByString("@")[0])!
            }
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
    
    func stringGenderFromInt(int: Int) -> String {
        if int == 0 {
            return "male"
        }else if int == 1 {
            return "female"
        }else{
            return "unknown"
        }
    }
    
    func setGenderFromInt(int: Int) {
        self.gender = stringGenderFromInt(int)
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
