//
//  Auth+JSON.swift
//  BreakOut
//
//  Created by Mathias Quintero on 2/25/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import Sweeft

extension JSON {
    
    /// Type of media item
    var type: Type {
        return Type(from: self["type"]) ?? .none
    }
    
    /// Location
    var location: Location? {
        return Location(from: self)
    }
    
    /// Video
    var video: Video? {
        return Video(from: self)
    }
    
    /// Image
    var image: Image? {
        return Image(from: self)
    }
    
    /// Slightly smaller image for profile pictures
    var profilePic: Image? {
        return Image(from: self["profilePic"], height: 100)
    }
    
    /// Team
    var team: Team? {
        return Team(from: self)
    }
    
    /// Participant
    var participant: Participant? {
        return Participant(from: self)
    }
    
    var participants: [Participant] {
        return array ==> Participant.init
    }
    
    var messages: [Message] {
        return array ==> Message.init
    }
    
    /// Challenge
    var challenge: Challenge? {
        return Challenge(from: self)
    }
    
    /// URL of the video compatible if with the device
    var videoURL: String? {
        guard let url = self["url"].string, url.contains(".mp4"), self.type == .video else {
            return nil
        }
        return url
    }
    
    /// Array of media items
    var media: [MediaItem] {
        return array ==> MediaItem.init
    }
    
    /// Array of comments
    var comments: [Comment] {
        return array ==> Comment.init
    }
    
    var challengeStatus: Challenge.Status? {
        return Challenge.Status(from: self)
    }
    
    /**
     Returns if the size is of acceptable quality
     
     - Parameter requiredHeight: height of the view it will be displayed in
     
     - Returns: true if image is bigger
     */
    func isFitFor(height requiredHeight: Int) -> Bool {
        let height = self["width"].int.?
        let width = self["width"].int.?
        let size = max(width, height)
        return size >= requiredHeight
    }
    
}
