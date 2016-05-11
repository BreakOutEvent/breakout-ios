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

func getDocumentsURL() -> NSURL {
    let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
    return documentsURL
}

func fileInDocumentsDirectory(filename: String) -> String {
    
    let fileURL = getDocumentsURL().URLByAppendingPathComponent(filename)
    return fileURL.path!
    
}

@objc(BOImage)
class BOImage: NSManagedObject {
    @NSManaged var uploadToken: NSString
    @NSManaged var uid: NSInteger
    @NSManaged var type: NSString
    @NSManaged var url: NSString
    @NSManaged var filepath: NSString
    @NSManaged var flagNeedsUpload: Bool
    
    class func create(uid: Int, flagNeedsUpload: Bool) -> BOImage {
        let res = BOImage.MR_createEntity()! as BOImage
        
        res.uid = uid as NSInteger
        res.type = "image"
        res.flagNeedsUpload = flagNeedsUpload
        // Save
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
        return res;
    }
    
    class func createWithDictionary(dict: NSDictionary) -> BOImage {
        let res = BOImage.MR_createEntity()! as BOImage
        
        res.setAttributesWithDictionary(dict)
        
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
        
        return res
    }
    
    class func createWithImage(image: UIImage) -> BOImage {
        let res = BOImage.MR_createEntity()! as BOImage
        
        //Store the original image
        let imageData = UIImageJPEGRepresentation(image, 1)
        let relativePath:String = "image_\(NSDate.timeIntervalSinceReferenceDate()).jpg"
        let path:String = fileInDocumentsDirectory(relativePath)
        if imageData!.writeToFile(path, atomically: true) {
            BOToast.log("Storing image file was successful", level: BOToast.Level.Success)
        }else{
            BOToast.log("Error during storing of image file", level: BOToast.Level.Error)
        }
        
        res.type = "image"
        res.filepath = relativePath
        
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
        
        return res
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
    
    func uploadWithToken(id: Int, token: String) {
        uploadToken = token
        uid = id
        
        // TODO: Possible compression later.
        
        BONetworkManager.uploadMedia(id, token: token, data: uploadData(id), success: { () in
            print("Upload Succesful")
            self.flagNeedsUpload = false
        }) { () in
            print("Upload Not Succesful")
        }
    }

    // MARK: -
    
    
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
    
    func uploadData(id: Int) -> NSData {
        
        if let data = UIImageJPEGRepresentation(getImage(), 1.0) {
            let boundary = "randomBoundary"
            
            let fullData = NSMutableData()
            
            let lineOne = "--" + boundary + "\r\n"
            fullData.appendData(lineOne.dataUsingEncoding(
                NSUTF8StringEncoding,
                allowLossyConversion: false)!)
            
            let lineTwo = "Content-Disposition: form-data; name=\"file\"; filename=\"" + (filepath as String) + "\"\r\n"
            fullData.appendData(lineTwo.dataUsingEncoding(
                NSUTF8StringEncoding,
                allowLossyConversion: false)!)
            
            let lineThree = "Content-Type: image/jpg\r\n\r\n"
            fullData.appendData(lineThree.dataUsingEncoding(
                NSUTF8StringEncoding,
                allowLossyConversion: false)!)
            
            fullData.appendData(data)
            
            let lineFive = "\r\n"
            fullData.appendData(lineFive.dataUsingEncoding(
                NSUTF8StringEncoding,
                allowLossyConversion: false)!)
            
            let lineSix = "--" + boundary + "--\r\n"
            fullData.appendData(lineSix.dataUsingEncoding(
                NSUTF8StringEncoding,
                allowLossyConversion: false)!)
            
            let lineForID = "--\(boundary)\r\nContent-Disposition: form-data; name=\"id\";\r\nContent-Type: text/plain\r\n\(id)\r\n"
            fullData.appendData(lineForID.dataUsingEncoding(
                NSUTF8StringEncoding,
                allowLossyConversion: false)!)
            
            fullData.appendData(lineSix.dataUsingEncoding(
                NSUTF8StringEncoding,
                allowLossyConversion: false)!)
            
            
            
            return fullData
        }
        return NSData()
        
    }
    
}