//
//  UploadManager.swift
//  BreakOut
//
//  Created by Mathias Quintero on 2/25/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import AVFoundation
import Sweeft

struct MediaAPI: API {
    
    enum Endpoint: String, APIEndpoint {
        case upload = ""
    }
    
    static var shared: MediaAPI = {
        return .init(baseURL: "https://media.break-out.org")
    }()
    
    let baseURL: String
}

enum UploadManager {
    
    /**
     Upload a piece of data to the media-uploader
     
     - Parameter data: Data of the file you want to upload
     - Parameter id: Id given to it by the backend
     - Parameter token: Upload Token given by the backend
     - Parameter filename: name of the file
     - Parameter type: Mime Type
     
     */
    static func upload(data: Data, id: Int, token: String, filename: String, type: String) {
        
        var form = MultiformData()
        form[filename] = MultiformFile(data: data, mimeType: type)
        form["id"] = String(id)
        
        MediaAPI.shared.doRepresentedRequest(with: .post,
                                             to: .upload,
                                             headers: ["X-UPLOAD-TOKEN": token],
                                             body: form,
                                             acceptableStatusCodes: [200, 201]).onResult { (result: Result<Data, APIError>) in
            
            print(result)
        }
    }
    
}

extension UIImage {
    
    func upload(itemWith id: Int, using token: String) {
        guard let data = UIImageJPEGRepresentation(self, 0.75) else {
            return
        }
        UploadManager.upload(data: data, id: id, token: token, filename: "Image.jpg", type: "image/jpg")
    }
    
    func upload(using json: JSON) {
        guard let id = json["id"].int,
            let token = json["uploadToken"].string else {

            return
        }
        upload(itemWith: id, using: token)
    }
    
}

extension URL {
    
    func uploadVideo(with id: Int, using token: String) {
        let asset = AVAsset(url: self)
        let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(id)-Video.mp4")
        exporter?.outputFileType = AVFileTypeMPEG4
        exporter?.outputURL = url
        exporter?.exportAsynchronously {
            guard let data = try? Data(contentsOf: url) else {
                return
            }
            try? FileManager.default.removeItem(at: url)
            UploadManager.upload(data: data, id: id, token: token, filename: "Video.mp4", type: "video/mp4")
        }
    }
    
}
