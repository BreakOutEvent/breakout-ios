//
//  Video.swift
//  BreakOut
//
//  Created by Mathias Quintero on 2/25/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import Sweeft
import AVFoundation
import AVKit

/// Video
final class Video: Observable {
    
    var listeners = [Listener]()
    let id: Int
    var video: URL?
    private var player: AVPlayer?
    var image: Image? {
        didSet {
            hasChanged()
        }
    }
    
    /// Current Video Player with the video inside
    var videoPlayer: AVPlayer? {
        if let player = player {
            return player
        }
        if let video = video {
            player = AVPlayer(url: video)
            return player
        }
        return nil
    }
    
    /// Returns whether or not the video is playing
    var isPlaying: Bool {
        if let player = player {
            return player.rate != 0
        }
        return false
    }
    
    /// Returns whether or not there's an open session for the video
    var playbackSessionOpen: Bool {
        return player != nil
    }
    
    init(id: Int, image: Image?, url: String?) {
        self.id = id
        self.image = image
        video = url | URL.init(string:) ?? nil
    }
    
    /// Play the video
    func play() {
        player?.play()
    }
    
    /// Pause the video
    func pause() {
        player?.pause()
    }
    
    /// Stop the video and the session
    func stop() {
        player?.pause()
        player = nil
    }
    
}

extension Video: Deserializable {
    
    convenience init?(from json: JSON) {
        guard let id = json["id"].int else {
            return nil
        }
        let sizes = json["sizes"].array ==> { $0.videoURL }
        self.init(id: id, image: json.image, url: sizes.first)
    }
    
}

extension Video: Equatable {
    
    static func ==(lhs: Video, rhs: Video) -> Bool {
        return lhs.id == rhs.id && lhs.video == rhs.video
    }
    
}
