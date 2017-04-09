//
//  Post.swift
//  BreakOut
//
//  Created by Mathias Quintero on 2/25/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import Sweeft

/// Represents a Posting
final class Post: Observable {
    
    var listeners = [Listener]()
    let id: Int
    let text: String?
    let date: Date
    let participant: Participant
    let location: Location?
    let challenge: Challenge?
    let media: [MediaItem]
    let hashtags: [String]
    var comments: [Comment]
    var liked: Bool
    var likes: Int
    
    init(id: Int,
         text: String? = nil,
         date: Date,
         participant: Participant,
         location: Location?,
         challenge: Challenge? = nil,
         media: [MediaItem] = .empty,
         hashtags: [String] = .empty,
         comments: [Comment] = .empty,
         liked: Bool = false,
         likes: Int = 0) {
        
        self.id = id
        self.text = text
        self.date = date
        self.participant = participant
        self.location = location
        self.challenge = challenge
        self.media = media
        self.hashtags = hashtags
        self.comments = comments
        self.liked = liked
        self.likes = likes
        (media ==> { $0.video }) >>> **self.hasChanged
        (media ==> { $0.internalImage}) >>> **self.hasChanged
        comments >>> **self.hasChanged
        participant >>> **self.hasChanged
    }
    
}

extension Post: Deserializable {
    
    convenience init?(from json: JSON) {
        guard let id = json["id"].int,
            let date = json["date"].date(),
            let participant = json["user"].participant else {
                return nil
        }
        let location = json["postingLocation"].location
        self.init(id: id, text: json["text"].string,
                  date: date, participant: participant,
                  location: json["postingLocation"].location,
                  challenge: json["proves"].challenge,
                  media: json["media"].media,
                  hashtags: json["hashtags"].array ==> { $0.string },
                  comments: json["comments"].comments,
                  liked: json["hasLiked"].bool.?,
                  likes: json["likes"].int.?)
    }
    
}

extension Post {
    
    /**
     Fetches **ALL** of the postings
     
     - Parameter api: Break Out backend from which it should fetch them
     
     - Returns: Promise of the Postings
     */
    static func all(using api: BreakOut = .shared) -> Post.Results {
        let user = CurrentUser.shared.id
        return getAll(using: api, at: .postings, queries: ["userid": user])
    }
    
    /**
     Fetches postings from a team in an event
     
     - Parameter team: id of the team
     - Parameter event: id of the event
     - Parameter api: Break Out backend from which it should fetch them
     
     - Returns: Promise of the Postings
     */
    static func all(by team: Int, page: Int = 0, in event: Int, using api: BreakOut = .shared) -> Post.Results {
        let user = CurrentUser.shared.id
        return getAll(using: api, at: .postingByTeam, arguments: ["event": event, "team": team], queries: ["page": page, "userid": user])
    }
    
    /**
     Fetches a specific posting
     
     - Parameter id: id of the posting
     - Parameter api: Break Out backend from which it should fetch it
     
     - Returns: Promise of the Posting
     */
    static func posting(with id: Int, using api: BreakOut = .shared) -> Post.Result {
        let user = CurrentUser.shared.id
        return Post.get(using: api, method: .get, at: .postingByID, arguments: ["id": id], queries: ["userid": user])
    }
    
    /**
     Fetches postings with certain ids
     
     - Parameter ids: Array of ids you want to fetch
     - Parameter api: Break Out backend from which it should fetch them
     
     - Returns: Promise of the Postings
     */
    static func postings(with ids: [Int], using api: BreakOut = .shared) -> Post.Results {
        let user = CurrentUser.shared.id
        return api.doObjectsRequest(with: .post, to: .notLoadedPostings, queries: ["userid": user], body: ids.json)
    }
    
    /**
     Fetches postings that use a hashtag
     
     - Parameter hashtag: hashtag you're looking for
     - Parameter api: Break Out backend from which it should fetch them
     
     - Returns: Promise of the Postings
     */
    static func postings(with hashtag: String, usign api: BreakOut = .shared) -> Post.Results {
        let user = CurrentUser.shared.id
        return getAll(using: api, at: .postingsForHashtag, arguments: ["hashtag": hashtag], queries: ["userid": user])
    }
    
    /**
     Fetches postings in a page
     
     - Parameter page: index of the page
     - Parameter size: size of the page
     - Parameter api: Break Out backend from which it should fetch them
     
     - Returns: Promise of the Postings
     */
    static func get(page: Int, using api: BreakOut = .shared) -> Post.Results {
        let user = CurrentUser.shared.id
        return getAll(using: api, at: .postings, queries: ["page": page, "userid": user])
    }
    
}

extension Post {
    
    /**
     Posts a new posting
     
     - Parameter text: text content in the posting
     - Parameter latitude: current latitude
     - Parameter longitude: current longitude
     - Parameter city: current location
     - Parameter challenge: challenge being completed
     - Parameter media: media items that should be uploaded
     - Parameter api: Break Out backend it should send the posting to
     
     - Returns: Promise of the generated Post
     */
    static func post(text: String,
                     latitude: Double,
                     longitude: Double,
                     city: String?,
                     challenge: Challenge?,
                     media: [NewMedia] = .empty,
                     api: BreakOut = .shared) -> Post.Result {
        
        let post = NewPost(text: text, date: .now, latitude: latitude, longitude: longitude, media: media)
        return api.doJSONRequest(with: .post,
                                 to: .postings,
                                 auth: api.auth,
                                 body: post.json,
                                 acceptableStatusCodes: [200, 201]).nested { json, promise in

            if let post = Post(from: json) {
                media => { item, index in
                    item.upload(using: json["media"][index])
                }
                challenge?.set(status: .proven, for: post)
                promise.success(with: post)
            } else {
                promise.error(with: .mappingError(json: json))
            }
        }
    }
    
}

extension Post {
    
    /**
     Toggles the current status of the like
     
     - Parameter api: Break Out backend
     
     - Returns: Promise of the JSON
     */
    @discardableResult func toggleLike(using api: BreakOut = .shared) -> JSON.Result {
        return (liked ? self.unlike : self.like)(api)
    }
    
    /**
     Like the posting
     
     - Parameter api: Break Out backend
     
     - Returns: Promise of the JSON
     */
    @discardableResult func like(using api: BreakOut = .shared) -> JSON.Result {
        let body: JSON = [
            "date": Date.now.timeIntervalSince1970
        ]
        return api.doJSONRequest(with: .post,
                                 to: .likePosting,
                                 arguments: ["id": id],
                                 auth: api.auth,
                                 body: body,
                                 acceptableStatusCodes: [200, 201]).nested { (json: JSON) in
                self.likes += 1
                self.liked = true
                self.hasChanged()
                return json
        }
    }
    
    /**
     Unlike the posting
     
     - Parameter api: Break Out backend
     
     - Returns: Promise of the JSON
     */
    @discardableResult func unlike(using api: BreakOut = .shared) -> JSON.Result {
        return api.doJSONRequest(with: .delete,
                                 to: .likePosting,
                                 arguments: ["id": id],
                                 auth: api.auth).nested { (json: JSON) in
            
            self.likes -= 1
            self.liked = false
            self.hasChanged()
            return json
        }
    }
    
    /**
     Post a comment to the posting
     
     - Parameter comment: Comment you want to post
     - Parameter api: Break Out backend
     
     - Returns: Promise of the generated Comment
     */
    @discardableResult func comment(_ comment: String, using api: BreakOut = .shared) -> Comment.Result {
        let comment = NewComment(post: self, comment: comment, user: .shared, date: .now)
        return api.doObjectRequest(with: .post,
                            to: .postComment,
                            arguments: ["id": self.id],
                            auth: api.auth,
                            body: comment.json,
                            acceptableStatusCodes: [201]).nested { (comment: Comment) in
                                
                                comment >>> **self.hasChanged
                                self.comments.append(comment)
                                self.hasChanged()
                                return comment
        }
    }
    
}
