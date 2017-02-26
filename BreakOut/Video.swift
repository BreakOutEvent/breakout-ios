//
//  Video.swift
//  BreakOut
//
//  Created by Mathias Quintero on 2/25/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import Sweeft
import AVFoundation

final class Video: Observable {
    
    var listeners = [Listener]()
    let id: Int
    var video: AVPlayerItem? {
        didSet {
            hasChanged()
        }
    }
    var image: Image? {
        didSet {
            hasChanged()
        }
    }
    
    init(id: Int, image: Image?, url: String?) {
        self.id = id
        self.image = image
        if let url = url | URL.init(string:) ?? nil {
            self.video = AVPlayerItem(url: url)
        }
    }
    
}

extension Video: Deserializable {
    
    convenience init?(from json: JSON) {
        guard let id = json["id"].int else {
            return nil
        }
        let sizes = json["sizes"].array |> { $0.type == .video }
        self.init(id: id, image: json.image, url: sizes.first?["url"].string)
    }
    
}
