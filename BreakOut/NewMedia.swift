//
//  NewMedia.swift
//  BreakOut
//
//  Created by Mathias Quintero on 2/25/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import Foundation
import Sweeft
import AVFoundation

enum NewMedia {
    case image(UIImage)
    case video(URL)
    
    var type: String {
        switch self {
        case .image:
            return "IMAGE"
        case .video:
            return "VIDEO"
        }
    }
    
    /// Preview image that can be displayed
    var previewImage: UIImage? {
        switch self {
        case .image(let image):
            return image
        case .video(let url):
            let asset = AVAsset(url: url)
            let generator = AVAssetImageGenerator(asset: asset)
            let time = CMTime(seconds: 0, preferredTimescale: 60)
            return try? generator.copyCGImage(at: time, actualTime: nil) | UIImage.init(cgImage:)
        }
    }
    
    /// Upload a media item using an id and a token
    func upload(id: Int, token: String) {
        switch self {
        case .image(let image):
            image.upload(itemWith: id, using: token)
        case .video(let url):
            url.uploadVideo(with: id, using: token)
        }
    }
    
    /// Upload a media item using the id and token from json
    func upload(using json: JSON) {
        guard let id = json["id"].int,
            let token = json["uploadToken"].string else {
                
                return
        }
        upload(id: id, token: token)
    }
    
}

extension NewMedia {
    
    /// Initialize from the info from UIImagePickerController
    init?(from info: [String:Any]) {
        switch info[UIImagePickerControllerMediaType] as? String ?? "" {
        case "public.image":
                guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else {
                    return nil
                }
                self = .image(image)
        case "public.movie":
            guard let url = info[UIImagePickerControllerMediaURL] as? URL else {
                return nil
            }
            self = .video(url)
        default:
            return nil
        }
    }
    
}
