//
//  NewMedia.swift
//  BreakOut
//
//  Created by Mathias Quintero on 2/25/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import Foundation

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
    
    func upload(id: Int, token: String) {
        switch self {
        case .image(let image):
            image.upload(itemWith: id, using: token)
        case .video(let url):
            url.uploadVideo(with: id, using: token)
        }
    }
}
