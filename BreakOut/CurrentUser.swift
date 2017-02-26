//
//  CurrentUser.swift
//  BreakOut
//
//  Created by Leo Käßner on 10.01.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit
import Sweeft

import AFOAuth2Manager

// TODO: Refactor this huge singleton too. It's a mess => Use StatusSerializable for persisntance

final class CurrentUser: NSObject {
    var userid: NSInteger?
    let KEY_USERID: String = "userid"
    
    var firstname: String?
    
    var lastname: String?
    var email: String?
    var picture: UIImage?
    var profilePic: Image? {
        didSet {
            profilePic >>> {
                self.picture <- $0.image
            }
        }
    }
    
    var gender: String? // "male"=0 or "female"=1
    var birthday: Date?
    
    var emergencyNumber: String?
    let KEY_EMERGENCYNUMBER: String = "emergencynumber"
    
    var phoneNumber: String?
    let KEY_PHONENUMBER: String = "phonenumber"
    
    var shirtSize: String?
    
    var hometown: String?
    
    var flagBlocked: Bool = false
    
    var flagParticipant: Bool = false
    var teamid: NSInteger?
    var eventid: NSInteger?
    
    static var shared = CurrentUser()
    
    override fileprivate init() {
        super.init()
        
        self.retrieveFromNSUserDefaults()
    }
    
    static func resetUser() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "userDictionary")
        defaults.synchronize()
        self.shared = CurrentUser()
    }
    
    func presentLoginScreenFromViewController(_ fromView: UIViewController) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginRegisterViewController: LoginRegisterViewController = storyboard.instantiateViewController(withIdentifier: "LoginRegisterViewController") as! LoginRegisterViewController
        
        fromView.present(loginRegisterViewController, animated: true, completion: nil)
    }
    
// MARK: - Sync with Backend
    
    func uploadUserData(to api: BreakOut = .shared) {
        
        if let id = self.userid {
            let params = self.attributesAsDictionary()
            
            let dictionary = params.dictionaryWithValues(forKeys: params.allKeys ==> { $0 as? String })
            let json = JSON(from: dictionary) // Small hack
            BONetworkIndicator.si.increaseLoading()
            
            api.doJSONRequest(with: .post, to: .userData, arguments: ["id": id], auth: LoginManager.auth, body: json).onSuccess { response in
                 BONetworkIndicator.si.decreaseLoading()
            }
            .onError { error in
                BONetworkIndicator.si.decreaseLoading()
                switch error {
                case .invalidStatus(401, _):
                    NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION_PRESENT_LOGIN_SCREEN), object: nil)
                default: break
                }
            }
            print("Got it!")
        }
    }
    
    func downloadUserData() {
        if self.isLoggedIn() {
            BONetworkIndicator.si.increaseLoading()
            
            CurrentUser.get().onSuccess { _ in
                BONetworkIndicator.si.decreaseLoading()
            }
            .onError { error in
                BONetworkIndicator.si.decreaseLoading()
                switch error {
                case .invalidStatus(401, _):
                    NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION_PRESENT_LOGIN_SCREEN), object: nil)
                default: break
                }
            }
        }        
    }
    
    func register(email: String, password: String, using api: BreakOut = .shared) -> CurrentUser.Result {
        let body: JSON = [
            "email": email.json,
            "password": password.json
        ]
        return api.doJSONRequest(with: .post, to: .user, body: body, acceptableStatusCodes: [200, 201]).nested { (json: JSON) in
            self.set(with: json)
            self.email = email
            self.storeInNSUserDefaults()
            return self
        }
    }
    
    
// MARK: - Storing & Retrieving
    
    func attributesAsDictionary() -> NSMutableDictionary {
        let selfDictionary: NSMutableDictionary = NSMutableDictionary()
        if self.userid != nil {
            selfDictionary.setObject(self.userid!, forKey: KEY_USERID as NSCopying)
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
        if self.teamid != nil {
            selfDictionary.setValue(self.teamid, forKey: "teamId")
        }
        if self.eventid != nil {
            selfDictionary.setValue(self.eventid, forKey: "eventId")
        }
        
        selfDictionary.setValue(self.flagParticipant, forKey: "flagParticipant")
        selfDictionary.setValue(self.flagBlocked, forKey: "flagBlocked")
        
        return selfDictionary
    }
    
    func storeInNSUserDefaults() {
        //Write login data in UserDefaults
        let defaults = UserDefaults.standard
        
        let selfDictionary: NSMutableDictionary = self.attributesAsDictionary()
        
        //Store the user image
        if self.picture != nil {
            let imageData = UIImageJPEGRepresentation(self.picture!, 1)
            let relativePath = "image_\(Date.timeIntervalSinceReferenceDate).jpg"
            let path = self.documentsPathForFileName(relativePath)
            try? imageData!.write(to: URL(fileURLWithPath: path), options: [.atomic])
        
            selfDictionary.setValue(relativePath, forKey: "picture")
        }
        
        
        defaults.set(selfDictionary, forKey: "userDictionary")
        defaults.synchronize()
        
        self.uploadUserData()
    }
    
    func retrieveFromNSUserDefaults() {
        //Write login data in UserDefaults
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "userDictionary") != nil {
            let selfDictionary:NSDictionary = defaults.object(forKey: "userDictionary") as! NSDictionary
            self.setAttributesWithJSON(selfDictionary)
            //self.setValuesForKeysWithDictionary(selfDictionary as! [String : AnyObject])
        }
    }
    
    func set(with json: JSON) {
        userid = json["id"].int
        firstname = json["firstname"].string
        lastname = json["lastname"].string
        email = json["email"].string
        gender = json["gender"].string
        birthday = json["birthday"].date()
        hometown = json["hometown"].string
        shirtSize = json["tshirtsize"].string
        emergencyNumber = json["emergencynumber"].string
        phoneNumber = json[KEY_PHONENUMBER].string
        profilePic = json.profilePic
        teamid = json["participant"]["teamId"].int
        eventid = json["participant"]["teamId"].int
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION_CURRENT_USER_UPDATED), object: nil)
    }
    
    func setAttributesWithJSON(_ jsonDictionary: NSDictionary) {
        for (key, value) in jsonDictionary {
            if !(value as AnyObject).isKind(of: NSNull.self) {
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
                }else if keyName == "hometown" || keyName == "eventCity" {
                    self.hometown = keyValue as? String
                }else if keyName == "gender" {
                    self.gender = keyValue as? String
                }else if keyName == "birthday" || keyName == "birthdate" {
                    self.birthday = keyValue as? Date
                }else if keyName == "tshirtsize" {
                    self.shirtSize = keyValue as? String
                }else if keyName == "emergencynumber" {
                    self.emergencyNumber = keyValue as? String
                }else if keyName == KEY_PHONENUMBER {
                    self.phoneNumber = keyValue as? String
                }else if keyName == "picture" {
                    let imageFullPath = self.documentsPathForFileName(keyValue as! String)
                    let userImageData = try? Data(contentsOf: URL(fileURLWithPath: imageFullPath))
                    // here is your saved image:
                    if userImageData != nil {
                        self.picture = UIImage(data: userImageData!)
                    }
                }else if keyName == "flagBlocked" {
                    self.flagBlocked = (keyValue as? Bool)!
                }else if keyName == "flagParticipant" {
                    self.flagParticipant = (keyValue as? Bool)!
                }else if keyName == "teamId" {
                    self.teamid = (keyValue as? NSInteger)!
                }else if keyName == "eventId" {
                    self.eventid = (keyValue as? NSInteger)!
                }
            }
        }
    }
    
// MARK: - Return Value Helpers
    
    func isLoggedIn() -> Bool {
        if self.email != nil {
            if self.email != "" {
                return true
            }
        }
        return false
    }
    
    func username() -> String {
        var username = ""
        if self.firstname != nil {
            username.append(self.firstname!)
            username.append(" ")
        }
        if self.lastname != nil {
            username.append(self.lastname!)
        }
        
        if username == "" || username == " " {
            if self.email != nil {
                username = (self.email?.components(separatedBy: "@")[0])!
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
    
    func stringGenderFromInt(_ int: Int) -> String {
        if int == 0 {
            return "male"
        }else if int == 1 {
            return "female"
        }else{
            return "unknown"
        }
    }
    
    func setGenderFromInt(_ int: Int) {
        self.gender = stringGenderFromInt(int)
    }
    
    func currentTeamId() -> Int {
        if self.teamid != nil {
            return self.teamid!
        }else{
            return -1
        }
    }
    
    func currentEventId() -> Int {
        if self.eventid != nil {
            return self.eventid!
        }else{
            return -1
        }
    }

// MARK: - Image Storing Helpers
    
    func getDocumentsURL() -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsURL
    }
    
    func fileInDocumentsDirectory(_ filename: String) -> String {
        
        let fileURL = getDocumentsURL().appendingPathComponent(filename)
        return fileURL.path
        
    }
    
    func documentsPathForFileName(_ name: String) -> String {
        return fileInDocumentsDirectory(name)

    }
}

extension CurrentUser: Serializable {
    
    var json: JSON {
        return [
            "firstname": (firstname.?).json,
            "lastname": (lastname.?).json
        ]
    }
    
}

extension CurrentUser: Deserializable {
    
    public convenience init?(from json: JSON) {
        // Not my best work, I admit ;)
        self.init()
        set(with: json)
        storeInNSUserDefaults()
        CurrentUser.shared = self
    }
    
}

extension CurrentUser {
    
    static func get(using api: BreakOut = .shared) -> CurrentUser.Result {
        return get(using: api, at: .currentUser, auth: LoginManager.auth)
    }
    
}
