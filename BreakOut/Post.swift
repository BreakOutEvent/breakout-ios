//
//  Post.swift
//  BreakOut
//
//  Created by Mathias Quintero on 2/25/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import Sweeft

final class Post: Observable {
    
    var listeners = [Listener]()
    let id: Int
    let text: String?
    let date: Date
    let participant: Participant
    let location: Location?
    let challenge: Challenge?
    let media: [MediaItem]
    var comments: [PostComment]
    let likes: Int
    
    init(id: Int, text: String? = nil, date: Date, participant: Participant, location: Location?, challenge: Challenge? = nil, media: [MediaItem] = [], comments: [PostComment] = [], likes: Int = 0) {
        self.id = id
        self.text = text
        self.date = date
        self.participant = participant
        self.location = location
        self.challenge = challenge
        self.media = media
        self.comments = comments
        self.likes = likes
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
        self.init(id: id, text: json["text"].string,
                  date: date, participant: participant,
                  location: json["postingLocation"].location,
                  media: json["media"].media,
                  comments: json["comments"].comments,
                  likes: json["likes"].int.?)
    }
    
}

extension Post {
    
    static func all(using api: BreakOut = .shared) -> Post.Results {
        return getAll(using: api, at: .postings)
    }
    
    static func all(since id: Int, using api: BreakOut = .shared) -> Post.Results {
        return getAll(using: api, at: .postingsSince, arguments: ["id": id])
    }
    
    static func posting(with id: Int, using api: BreakOut = .shared) -> Post.Result {
        return Post.get(using: api, method: .get, at: .postingByID, arguments: ["id": id])
    }
    
    static func postings(with ids: [Int], using api: BreakOut = .shared) -> Post.Results {
        return api.doObjectsRequest(with: .post, to: .notLoadedPostings, body: ids.json)
    }
    
    static func get(page: Int, of size: Int = 20, using api: BreakOut = .shared) -> Post.Results {
        return getAll(using: api, at: .postings, queries: ["offset": page, "limit": size])
    }
    
    static func get(team: Int, event: Int, using api: BreakOut = .shared) -> Post.Results {
        return api.doJSONRequest(to: .postingIdsForTeam, arguments: ["team": team, "event": event]).onError { error in
            switch error {
            case .invalidStatus(_, let data):
                if let string = data?.string {
                    print(string)
                }
            default: break
            }
        }
        .onSuccess { json -> Post.Results in
            let ids = json.array ==> { $0.int }
            return Post.postings(with: ids)
        }
        .future
    }
    
}

extension Post {
    
    static func post(text: String,
                     latitude: Double,
                     longitude: Double,
                     city: String?,
                     challenge: Challenge?,
                     media: [NewMedia],
                     api: BreakOut = .shared) -> Post.Result {
        
        let body: JSON = [
            "text": text.json,
            "date": Date.now.timeIntervalSince1970.json,
            "postingLocation": [
                "latitude": latitude.json,
                "longitude": longitude.json,
            ].json,
            "uploadMediaTypes": (media => { $0.type }).json
        ]
        let promise = api.doJSONRequest(with: .post,
                                        to: .postings,
                                        auth: LoginManager.auth,
                                        body: body,
                                        acceptableStatusCodes: [200, 201])
        
        promise.onSuccess { json in
            media => { item, index in
                guard let id = json["media"][index]["id"].int,
                    let token = json["media"][index]["uploadToken"].string else {
                        
                        return
                }
                item.upload(id: id, token: token)
            }
        }
        return promise.nested { json, promise in
            if let team = Post(from: json) {
                promise.success(with: team)
            } else {
                promise.error(with: .mappingError(json: json))
            }
        }
    }
    
}

extension Post {
    
    @discardableResult func comment(_ comment: String, using api: BreakOut = .shared) -> PostComment.Result {
        let comment = NewComment(post: self, comment: comment, user: .shared, date: .now)
        return api.doObjectRequest(with: .post,
                            to: .postComment,
                            arguments: ["id": self.id],
                            auth: LoginManager.auth,
                            body: comment.json,
                            acceptableStatusCodes: [201]).nested { (comment: PostComment) in
                                
                                comment >>> **self.hasChanged
                                self.comments.append(comment)
                                self.hasChanged()
                                return comment
        }
    }
    
}
