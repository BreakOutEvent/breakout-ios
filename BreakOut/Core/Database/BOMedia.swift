//
//  BOImage.swift
//  BreakOut
//
//  Created by Leo Käßner on 24.04.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import SwiftyJSON
import Sweeft

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

enum MediaType: String {
    case image = "image"
    case video = "video"
    case audio = "audio"
}

final class BOMedia {
    
    static var items: [Int : BOMedia]
    
    typealias MediaDownloadHandler = (BOMedia) -> ()
    
    var uploadToken: String?
    var uuid: Int
    var type: MediaType
    var url: String?
    var filepath: String?
    var flagNeedsUpload: Bool
    var needsBetterDownload: Bool
    var betterDownloadUrl: String?
    
    init(uuid: Int, uploadToken: String? = nil, type: MediaType = .image, url: String? = nil, filepath: String? = nil, flagNeedsUpload: Bool = true, needsBetterDownload: Bool = false, betterDownloadUrl: String? = nil, onDownload: MediaDownloadHandler? = nil) {
        self.uuid = uuid
        self.uploadToken = uploadToken
        self.type = type
        self.url = url
        self.filepath = filepath
        self.flagNeedsUpload = flagNeedsUpload
        self.needsBetterDownload = needsBetterDownload
        self.betterDownloadUrl = betterDownloadUrl
        if let url = url {
            BOImageDownloadManager.shared.getImage(uuid, url: url) { image in
                self.writeImage(image)
                onDownload?(self)
            }
        }
    }
    
    convenience init(from image: UIImage) {
        self.init(uuid: 0)
        writeImage(image)
    }
    
    required convenience init?(from json: JSON) {
        guard let id = json["id"].int else {
            return nil
        }
        let deviceHeight = UIScreen.main.bounds.height
        let image = (json["sizes"].array |> { item in
            (item["height"].int | { $0 <= deviceHeight }) ?? false
        }).first
        self.init(uuid: id, url: image["url"].string, flagNeedsUpload: false)
    }

    var image: UIImage? {
        if let imageFullPath = filepath | fileInDocumentsDirectory, let url = URL(fileURLWithPath: imageFullPath) {
            let userImageData = try? Data(contentsOf: url)
            let image = (userImageData | UIImage.init) ?? nil
            return image
        }
        return nil
    }
    
    func upload() {
        if (self.uid != 0 && self.uploadToken != "") {
            self.uploadWithToken(self.uid, token: self.uploadToken as String)
        }
    }
    
    func uploadWithToken(_ id: Int, token: String) {
        uploadToken = token
        uuid = id
        
        // TODO: Possible compression later.
        
        if let data = UIImageJPEGRepresentation(image, 1) {
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
        let currentPath = filepath
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
        let relativePath = "image_\(Date.timeIntervalSinceReferenceDate).jpg"
        let path = fileInDocumentsDirectory(relativePath)
        if ((try? imageData?.write(to: URL(fileURLWithPath: path), options: [.atomic])) != nil) ?? false {
            //BOToast.log("Storing image file was successful", level: BOToast.Level.Success)
        } else {
            //BOToast.log("Error during storing of image file", level: BOToast.Level.Error)
        }
        filepath = relativePath
        save()
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

extension BOMedia: BOObject {
    
    var json: JSON {
        return JSON([:])
    }
    
}

extension JSON {
    
    var media: BOMedia? {
        return BOMedia.create(from: self)
    }
    
    var mediaStuffs: [BOMedia]? {
        return BOMedia.array(from: self)
    }
    
}
