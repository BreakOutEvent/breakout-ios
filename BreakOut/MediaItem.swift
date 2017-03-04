//
//  MediaItem.swift
//  BreakOut
//
//  Created by Mathias Quintero on 2/25/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import Sweeft

enum MediaItem {
    case image(Image)
    case video(Video)
    
    var video: Video? {
        switch self {
        case .video(let video):
            return video
        default:
            return nil
        }
    }
    
    var image: UIImage? {
        switch self {
        case .image(let image):
            return image.image
        case .video(let video):
            return video.image?.image
        }
    }
}

extension MediaItem: Deserializable {
    
    public init?(from json: JSON) {
        switch json.type {
        case .video:
            guard let video = json.video else {
                return nil
            }
            self = .video(video)
        case .image:
            guard let image = json.image else {
                return nil
            }
            self = .image(image)
        default:
            return nil
        }
    }
    
}
