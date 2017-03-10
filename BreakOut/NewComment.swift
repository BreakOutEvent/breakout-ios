//
//  NewComment.swift
//  BreakOut
//
//  Created by Mathias Quintero on 2/25/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import Sweeft

/// Helper struct for a locally defined comment
struct NewComment {
    let post: Post
    let comment: String
    let user: CurrentUser
    let date: Date
}

extension NewComment: Serializable {
    
    var json: JSON {
        return [
            "date": date.timeIntervalSince1970.json,
            "text": comment.json,
            "postID": post.id.json,
            "user": user.json
        ]
    }
    
}
