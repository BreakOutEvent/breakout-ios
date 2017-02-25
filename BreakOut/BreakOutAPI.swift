//
//  BreakOutAPI.swift
//  BreakOut
//
//  Created by Mathias Quintero on 1/11/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import Sweeft
import AVFoundation
import AFOAuth2Manager
import UIKit
import CoreLocation

enum BOEndpoint: String, APIEndpoint {
    case user = "user/"
    case userData = "user/{id}/"
    case currentUser = "me/"
    case postingsSince = "posting/get/since/{id}/"
    case postings = "posting/"
    case postComment = "posting/{id}/comment/"
    case postingIdsForTeam = "event/{event}/team/{team}/posting/"
    case notLoadedPostings = "posting/get/ids/"
    case eventInvitation = "event/{event}/team/{id}/invitation/"
    case eventTeam = "event/{event}/team/"
    case eventAllLocations = "event/{event}/location/"
    case event = "event/"
    case eventTeamLocation = "event/{event}/team/{team}/location/"
    case featureFlags = "featureFlags/"
    case postingByID = "posting/{id}/"
    case eventTeamChallenge = "event/{event}/team/{team}/challenge/"
    case challengeStatus = "event/{event}/team/{team}/challenge/{challenge}/status/"
}

struct BreakOut: API {
    typealias Endpoint = BOEndpoint
    
    var baseURL: String
    
    static var shared = BreakOut()
}

extension BreakOut {
    
    init() {
        self.init(baseURL: PrivateConstants().backendURL())
    }
    
}

extension AFOAuthCredential: Auth {
    
    public func apply(to request: inout URLRequest) {
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    }
    
}

struct Event {
    let id: Int
    let title: String
    let city: String
    let date: Date
}

extension Event: Deserializable {
    
    public init?(from json: JSON) {
        guard let id = json["id"].int,
            let title = json["title"].string,
            let city = json["city"].string,
            let date = json["date"].date() else {
                
            return nil
        }
        self.init(id: id, title: title, city: city, date: date)
    }
    
}

extension Event {
    
    static func all(using api: BreakOut = .shared) -> Event.Results {
        return getAll(using: api, at: .event)
    }
    
}

final class Post: Observable {
    
    var listeners = [Listener]()
    let id: Int
    let text: String?
    let date: Date
    let participant: Participant
    let location: Location
    let challenge: Challenge?
    let media: [MediaItem]
    var comments: [PostComment]
    let likes: Int
    
    init(id: Int, text: String? = nil, date: Date, participant: Participant, location: Location, challenge: Challenge? = nil, media: [MediaItem] = [], comments: [PostComment] = [], likes: Int = 0) {
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
            let location = json["postingLocation"].location,
            let participant = json["user"].participant else {
                return nil
        }
        self.init(id: id, text: json["text"].string,
                  date: date, participant: participant,
                  location: location,
                  media: json["media"].media,
                  comments: json["comments"].comments,
                  likes: json["likes"].int.?)
    }
    
}

extension Post {
    
    static func all(using api: BreakOut = .shared) -> Post.Results {
        return getAll(using: api, at: .postings)
    }
    
    static func posting(with id: Int, using api: BreakOut = .shared) -> Post.Result {
        return Post.get(using: api, method: .get, at: .postingByID, arguments: ["id": id])
    }
    
    static func postings(with ids: [Int], using api: BreakOut = .shared) -> Post.Results {
        return api.doObjectsRequest(with: .post, to: .notLoadedPostings, body: ids.json)
    }
    
    static func postings(since id: Int, using api: BreakOut = .shared) -> Post.Results {
        return getAll(using: api, at: .postingsSince, arguments: ["id": id])
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
            let ids = json["ids"].array ==> { $0.int }
            return Post.postings(with: ids)
        }
        .future
    }
    
}

extension Post {
    
    func comment(_ comment: String, using api: BreakOut = .shared, completion: @escaping () -> ()) {
        let comment = NewComment(post: self, comment: comment, user: .shared, date: .now)
        api.doObjectRequest(with: .post,
                            to: .postComment,
                            arguments: ["id": self.id],
                            auth: BONetworkManager.auth,
                            body: comment.json,
                            acceptableStatusCodes: [201]).onSuccess { (comment: PostComment) in
                                
            comment >>> **self.hasChanged
            self.comments.append(comment)
            self.hasChanged()
            completion()
        }
    }
    
}

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

enum Type: String {
    case image = "IMAGE"
    case video = "VIDEO"
    case none = "NONE"
}

extension Type: Deserializable {
    
    public init?(from json: JSON) {
        guard let item = json.string | Type.init(rawValue:) ?? nil else {
            self = .none
            return
        }
        self = item
    }

}

enum MediaItem {
    case image(Image)
    case video(Video)
    
    var video: AVPlayerItem? {
        switch self {
        case .video(let video):
            return video.video
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

final class Image: Observable {
    
    var listeners = [Listener]()
    let id: Int
    var image: UIImage? {
        didSet {
            hasChanged()
        }
    }
    
    init(id: Int, image: UIImage) {
        self.id = id
        self.image = image
    }
    
    init(id: Int, url: String?) {
        self.id = id
        if let url = url | URL.init(string:) ?? nil {
            DispatchQueue(label: "Download").async {
                let data = try? Data(contentsOf: url)
                self.image <- data | UIImage.init
            }
        }
    }
    
}

extension Image: Deserializable {
    
    convenience init?(from json: JSON) {
        guard let id = json["id"].int else {
            return nil
        }
        let sizes = json["sizes"].array |> { $0.type == .image }
        self.init(id: id, url: sizes.first?["url"].string)
    }
    
}

struct PostComment {
    let id: Int
    let date: Date
    let text: String?
    let participant: Participant
}

extension PostComment: Deserializable {
    
    init?(from json: JSON) {
        guard let id = json["id"].int,
            let date = json["date"].date(),
            let participant = json["user"].participant else {
                
                return nil
        }
        self.init(id: id, date: date, text: json["text"].string, participant: participant)
    }
    
}

extension PostComment: ObservableContainer {
    
    var observable: Participant {
        return participant
    }
    
}

struct Location {
    let id: Int
    let date: Date
    let longitude: Double
    let latitude: Double
    let team: Team?
    let country: String?
    let locality: String?
}

extension Location: Deserializable {
    
    init?(from json: JSON) {
        guard let id = json["id"].int,
            let date = json["date"].date(),
            let latitude = json["latitude"].double,
            let longitude = json["longitude"].double else {
                return nil
        }
        self.init(id: id, date: date, longitude: longitude, latitude: latitude, team: json.team, country: json["locationData"]["COUNTRY"].string, locality: json["locationData"]["LOCALITY"].string)
    }
    
}

extension Location {
    
    static func all(for event: Int, using api: BreakOut = .shared) -> Location.Results {
        return getAll(using: api, at: .eventAllLocations, arguments: ["event": event])
    }
    
    static func all(forTeam team: Int, event: Int, using api: BreakOut = .shared) -> Location.Results {
        return getAll(using: api, at: .eventTeamLocation, arguments: ["event": event, "team": team])
    }
    
}

extension Location {
    
    var coordinates: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
}

struct Challenge {
    let id: Int
    let text: String?
    let status: String?
    let amount: Int?
}

extension Challenge: Deserializable {
    
    public init?(from json: JSON) {
        guard let id = json["id"].int else {
            return nil
        }
        self.init(id: id, text: json["description"].string, status: json["status"].string, amount: json["amount"].int)
    }
    
}

final class Participant: Observable {
    
    var listeners = [Listener]()
    let id: Int
    let name: String
    let team: Team?
    let image: Image?
    
    init(id: Int, name: String, team: Team?, image: Image?) {
        self.id = id
        self.name = name
        self.team = team
        self.image = image
        image >>> **self.hasChanged
    }
    
}

extension Participant: Deserializable {
    
    public convenience init?(from json: JSON) {
        guard let id = json["id"].int,
            let first = json["firstname"].string,
            let last = json["lastname"].string else {
                
            return nil
        }
        self.init(id: id, name: "\(first) \(last)", team: json["participant"].team, image: json["profilePic"].image)
    }
    
}

struct Team {
    let id: Int
    let name: String
}

extension Team: Deserializable {
    
    public init?(from json: JSON) {
        guard let id = json["teamId"].int ?? json["id"].int, let name = json["teamName"].string ?? json["name"].string else {
            return nil
        }
        self.init(id: id, name: name)
    }
    
}

extension Team {
    
    static func all(for event: Int, using api: BreakOut = .shared) -> Team.Results {
        return getAll(using: api, method: .get, at: .eventTeam, arguments: ["event": event])
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
