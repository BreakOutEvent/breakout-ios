//
//  BOImage.swift
//  BreakOut
//
//  Created by Leo Käßner on 24.04.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import Foundation

// Database
import MagicalRecord

// Tracking
import Flurry_iOS_SDK
import Crashlytics

func getDocumentsURL() -> NSURL {
    let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
    return documentsURL
}

func fileInDocumentsDirectory(filename: String) -> String {
    
    let fileURL = getDocumentsURL().URLByAppendingPathComponent(filename)
    return fileURL.path!
    
}

public extension UIImage {
    public func hasContent() -> Bool {
        let cgref = self.CGImage
        let cim = self.CIImage
        if cgref == nil && cim == nil {
            return false
        }else{
            return true
        }
    }
}

@objc(BOImage)
class BOImage: NSManagedObject {
    @NSManaged var uploadToken: NSString
    @NSManaged var uid: NSInteger
    @NSManaged var type: NSString
    @NSManaged var url: NSString
    @NSManaged var filepath: NSString
    @NSManaged var flagNeedsUpload: Bool
    @NSManaged var needsBetterDownload: Bool
    @NSManaged var betterDownloadUrl: String?
    
    class func create(uid: Int, flagNeedsUpload: Bool) -> BOImage {
        let res = BOImage.MR_createEntity()! as BOImage
        
        res.uid = uid as NSInteger
        res.type = "image"
        res.flagNeedsUpload = flagNeedsUpload
        // Save
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreWithCompletion(nil)
        return res;
    }
    
    class func createWithDictionary(dict: NSDictionary) -> BOImage {
        let res = BOImage.MR_createEntity()! as BOImage
        
        res.setAttributesWithDictionary(dict)
        
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreWithCompletion(nil)
        
        return res
    }
    
    class func createWithImage(image: UIImage) -> BOImage {
        let res = BOImage.MR_createEntity()! as BOImage
        res.writeImage(image)
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreWithCompletion(nil)
        
        return res
    }
    
    class func createFromDictionary(item: NSDictionary, success: (BOImage) -> ()) {
        if let id = item.valueForKey("id") as? Int, sizes = item.valueForKey("sizes") as? [NSDictionary] {
            let image: NSDictionary?
            let needsBetterDownload: Bool
            var betterURL: String?
            if BOSynchronizeController.sharedInstance.internetReachability == "wifi" {
                image = sizes.last
                needsBetterDownload = false
            } else {
                image = sizes.first
                needsBetterDownload = true
                if let last = sizes.last, lastURL = last.valueForKey("url") as? String {
                    betterURL = lastURL
                }
            }
            if let url = image?.valueForKey("url") as? String {
                BOImageDownloadManager.sharedInstance.getImage(id, url: url) { (image) in
                    image.needsBetterDownload = needsBetterDownload
                    image.betterDownloadUrl = betterURL
                    image.save()
                    success(image)
                }
            }
        }
    }

    func getImage() -> UIImage {
        let imageFullPath: String = fileInDocumentsDirectory(filepath as String)
        let userImageData = NSData(contentsOfFile: imageFullPath)
        // here is your saved image:
        if userImageData != nil {
            return UIImage(data: userImageData!)!
        }
        
        return UIImage()
    }
    
    func upload() {
        if (self.uid != 0 && self.uploadToken != "") {
            self.uploadWithToken(self.uid, token: self.uploadToken as String)
        }
    }
    
    func uploadWithToken(id: Int, token: String) {
        uploadToken = token
        uid = id
        
        // TODO: Possible compression later.
        
        if let data = UIImageJPEGRepresentation(getImage(), 1) {
            BONetworkManager.uploadMedia(id, token: token, data: data, filename: filepath as String,   success: { () in
                print("Upload Succesful")
                self.flagNeedsUpload = false
                Answers.logCustomEventWithName("/BOImage/upload", customAttributes: ["Successful":"true"])
            }) { () in
                print("Upload Not Succesful")
                Answers.logCustomEventWithName("/BOImage/upload", customAttributes: ["Successful":"false"])
            }
        }
        
    }

    // MARK: -
    
    func writeImage(image: UIImage) {
        //Store the original image
        let imageData = UIImageJPEGRepresentation(image, 1)
        let relativePath:String = "image_\(NSDate.timeIntervalSinceReferenceDate()).jpg"
        let path:String = fileInDocumentsDirectory(relativePath)
        if imageData!.writeToFile(path, atomically: true) {
            //BOToast.log("Storing image file was successful", level: BOToast.Level.Success)
        }else{
            //BOToast.log("Error during storing of image file", level: BOToast.Level.Error)
        }
        type = "image"
        filepath = relativePath
    }
    
    
    func setAttributesWithDictionary(dict: NSDictionary) {
        self.uid = dict.valueForKey("id") as! NSInteger
    }
    
    func save() {
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
    }
    
    func printToLog() {
        print("----------- BOImage -----------")
        print("ID: ", self.uid)
        print("Type: ", self.type)
        print("Filepath: ", self.filepath)
        print("URL: ", self.url)
        print("flagNeedsUpload: ", self.flagNeedsUpload)
        print("----------- ------ -----------")
    }
    
}