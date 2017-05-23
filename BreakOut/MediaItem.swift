//
//  MediaItem.swift
//  BreakOut
//
//  Created by Mathias Quintero on 2/25/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import Sweeft

enum MediaState {
    case processing
    case failed
    case ready
}

enum MediaItem {
    case image(Image)
    case video(Video)
    
    /// Video contained
    var video: Video? {
        switch self {
        case .video(let video):
            return video
        default:
            return nil
        }
    }
    
    var internalImage: Image? {
        switch self {
        case .image(let image):
            return image
        default:
            return nil
        }
    }
    
    /// Image that can be displayed
    var image: Image? {
        switch self {
        case .image(let image):
            return image
        case .video(let video):
            return video.image
        }
    }
    
    var isEmpty: Bool {
        switch self {
        case .image(let image):
            return image.isEmpty
        case .video(let video):
            return video.isEmpty
        }
    }
    
    func state(uploadedAt date: Date) -> MediaState {
        guard isEmpty else {
            return .ready
        }
        if Date.now.timeIntervalSince(date) < 10 * 60 {
            return .processing
        } else {
            return .failed
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
