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

func getDocumentsURL() -> URL {
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    return documentsURL
}

func fileInDocumentsDirectory(_ filename: String) -> String {
    
    let fileURL = getDocumentsURL().appendingPathComponent(filename)
    return fileURL.path
    
}

public extension UIImage {
    public func hasContent() -> Bool {
        let cgref = self.cgImage
        let cim = self.ciImage
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
    
    class func create(_ uid: Int, flagNeedsUpload: Bool) -> BOImage {
        let res = BOImage.mr_createEntity()! as BOImage
        
        res.uid = uid as NSInteger
        res.type = "image"
        res.flagNeedsUpload = flagNeedsUpload
        res.filepath = ""
        // Save
        NSManagedObjectContext.mr_default().mr_saveToPersistentStore(completion: nil)
        return res;
    }
    
    class func createWithDictionary(_ dict: NSDictionary) -> BOImage {
        let res = BOImage.mr_createEntity()! as BOImage
        
        res.setAttributesWithDictionary(dict)
        
        NSManagedObjectContext.mr_default().mr_saveToPersistentStore(completion: nil)
        
        return res
    }
    
    class func createWithImage(_ image: UIImage) -> BOImage {
        let res = BOImage.mr_createEntity()! as BOImage
        res.filepath = ""
        res.writeImage(image)
        NSManagedObjectContext.mr_default().mr_saveToPersistentStore(completion: nil)
        return res
    }
    
    class func createFromDictionary(_ item: NSDictionary, success: @escaping (BOImage) -> ()) {
        if let id = item.value(forKey: "id") as? Int, let sizes = item.value(forKey: "sizes") as? [NSDictionary] {
            let image: NSDictionary?
            let needsBetterDownload: Bool
            var betterURL: String?
            if BOSynchronizeController.sharedInstance.internetReachability == "wifi" {
                let deviceHeight = UIScreen.main.bounds.height
                image = sizes.filter() { item in
                    if let height = item.value(forKey: "height") as? Int {
                        return (CGFloat) (height) < deviceHeight
                    }
                    return false
                }.last
                needsBetterDownload = false
            } else {
                image = sizes.first
                needsBetterDownload = true
                if let last = sizes.last, let lastURL = last.value(forKey: "url") as? String {
                    betterURL = lastURL
                }
            }
            if let url = image?.value(forKey: "url") as? String {
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
        let userImageData = try? Data(contentsOf: URL(fileURLWithPath: imageFullPath))
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
    
    func uploadWithToken(_ id: Int, token: String) {
        uploadToken = token as NSString
        uid = id
        
        // TODO: Possible compression later.
        
        if let data = UIImageJPEGRepresentation(getImage(), 1) {
            BONetworkManager.uploadMedia(id, token: token, data: data, filename: filepath as String,   success: { () in
                print("Upload Succesful")
                self.flagNeedsUpload = false
                Answers.logCustomEvent(withName: "/BOImage/upload", customAttributes: ["Successful":"true"])
            }) { () in
                print("Upload Not Succesful")
                Answers.logCustomEvent(withName: "/BOImage/upload", customAttributes: ["Successful":"false"])
            }
        }
        
    }

    // MARK: -
    
    func writeImage(_ image: UIImage) {
        let currentPath = filepath as String
        if currentPath != "" {
            do {
                let fileManager = FileManager.default
                try fileManager.removeItem(atPath: currentPath)
            }
            catch let error as NSError {
                print("File Couldn't be deleted. \(error)")
            }
        }
        
        //Store the original image
        let imageData = UIImageJPEGRepresentation(image, 1)
        let relativePath:String = "image_\(Date.timeIntervalSinceReferenceDate).jpg"
        let path:String = fileInDocumentsDirectory(relativePath)
        if ((try? imageData?.write(to: URL(fileURLWithPath: path), options: [.atomic])) != nil) ?? false {
            //BOToast.log("Storing image file was successful", level: BOToast.Level.Success)
        }else{
            //BOToast.log("Error during storing of image file", level: BOToast.Level.Error)
        }
        type = "image"
        filepath = relativePath as NSString
        self.save()
    }
    
    
    func setAttributesWithDictionary(_ dict: NSDictionary) {
        self.uid = dict.value(forKey: "id") as! NSInteger
    }
    
    func save() {
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
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
