//
//  Auth+JSON.swift
//  BreakOut
//
//  Created by Mathias Quintero on 2/25/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import Sweeft
import AFOAuth2Manager

extension AFOAuthCredential: Auth {
    
    public func apply(to request: inout URLRequest) {
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    }
    
}

extension JSON {
    
    var type: Type {
        return Type(from: self["type"]) ?? .none
    }
    
    var location: Location? {
        return Location(from: self)
    }
    
    var video: Video? {
        return Video(from: self)
    }
    
    var image: Image? {
        return Image(from: self)
    }
    
    var media: [MediaItem] {
        return array ==> MediaItem.init
    }
    
    var comments: [PostComment] {
        return array ==> PostComment.init
    }
    
    var team: Team? {
        return Team(from: self)
    }
    
    var participant: Participant? {
        return Participant(from: self)
    }
    
}
