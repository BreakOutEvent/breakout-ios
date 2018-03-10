//
//  GroupMessage.swift
//  BreakOut
//
//  Created by Mathias Quintero on 3/27/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import Sweeft

/// Represents a Group Message
final class GroupMessage {
    
    let id: Int
    let users: [Participant]
    var messages: [Message]
 
    init(id: Int, users: [Participant], messages: [Message]) {
        self.id = id
        self.users = users
        self.messages = messages
    }
    
}

extension GroupMessage {
    
    var title: String {
        let members = users |> { $0.id != CurrentUser.shared.id } => { $0.firstName }
        return members.join()
    }
    
    func messageGroups(from index: Int = 0) ->  [(Int, [Message])] {
        return messages.array(from: index).reduce([]) { groups, message in
            var groups = groups
            guard let last = groups.popLast() else {
                return [(message.participant, [message])]
            }
            if last.0 == message.participant {
                return groups + [(last.0, last.1 + [message])]
            } else {
                let next = (message.participant, [message])
                return (groups + [last, next])
            }
        }
    }
    
}

extension GroupMessage {
    
    /// Last message sent in the group
    var lastMessage: String? {
        return messages.last?.text
    }
    
    /// Date of the last activity
    var lastActivity: Date? {
        return messages.last?.date
    }
    
}

extension GroupMessage: Deserializable {
    
    convenience init?(from json: JSON) {
        guard let id = json["id"].int else {
            return nil
        }
        self.init(id: id, users: json["users"].participants, messages: json["messages"].messages)
    }
    
}

extension GroupMessage {
    
    /**
     Will fetch all the open Group Messages for the current user
     
     - Parameter api: Break Out backend
     
     - Returns: Promise of the Group Message Object
     */
    static func all(using api: BreakOut = .shared) -> GroupMessage.Results {
        return api.doJSONRequest(to: .currentUser).flatMap { json in
            return GroupMessage.messages(with: json["groupMessageIds"].array ==> { $0.int }, using: api)
        }
    }
    
}

extension GroupMessage {
    
    /**
     Will fetch a group messge by it's id
     
     - Parameter id: id of the group message
     - Parameter api: Break Out backend
     
     - Returns: Promise of the Group Message Object
     */
    static func groupMessage(with id: Int, using api: BreakOut = .shared) -> GroupMessage.Result {
        return get(using: api, at: .message, arguments: ["id": id])
    }
    
    /**
     Will fetch a list of group messges by their ids
     
     - Parameter ids: ids of the group messages
     - Parameter api: Break Out backend
     
     - Returns: Promise of the Group Message Object
     */
    static func messages(with ids: [Int], using api: BreakOut = .shared) -> GroupMessage.Results {
        return api.doBulkObjectRequest(to: .message, arguments: ids => { ["id": $0] })
    }
    
    /**
     Fetch the latest information for the current group
     
     - Parameter api: Break Out backend
     
     - Returns: Promise of the Group Message Object (will be the same object)
     */
    @discardableResult func refresh(using api: BreakOut = .shared) -> GroupMessage.Result {
        return api.doJSONRequest(to: .message, arguments: ["id": id]).map { (json: JSON) in
            self.messages = json["messages"].messages
            return self
        }
    }
    
}

extension GroupMessage {
    
    /**
     Will create a Group Message with the given users in it
     
     - Parameter users: users in the group
     - Parameter api: Break Out backend
     
     - Returns: Promise of the Group Message Object
     */
    @discardableResult static func create(with users: [Participant], using api: BreakOut = .shared) -> GroupMessage.Result {
        return create(with: users => { $0.id }, using: api)
    }
    
    /**
     Will create a Group Message with the given users in it
     
     - Parameter users: users in the group
     - Parameter api: Break Out backend
     
     - Returns: Promise of the Group Message Object
     */
    @discardableResult static func create(with users: [Int], using api: BreakOut = .shared) -> GroupMessage.Result {
        return api.doObjectRequest(with: .post, to: .messages, body: users.json, acceptableStatusCodes: [200, 201])
    }
    
}

extension GroupMessage {
    
    /**
     Add a user to the Group
     
     - Parameter user: new user
     - Parameter api: Break Out backend
     
     - Returns: Promise of the Group Message Object (will be the same object)
     */
    func add(user: Participant, using api: BreakOut = .shared) -> GroupMessage.Result {
        return set(users: (users + [user]), using: api)
    }
    
    /**
     Remove a user from the group
     
     - Parameter user: removed user
     - Parameter api: Break Out backend
     
     - Returns: Promise of the Group Message Object (will be the same object)
     */
    func remove(user: Participant, using api: BreakOut = .shared) -> GroupMessage.Result {
        return set(users: users |> { $0.id != user.id })
    }
    
    /**
     Completely set the users of the group
     
     - Parameter users: users in the group
     - Parameter api: Break Out backend
     
     - Returns: Promise of the Group Message Object (will be the same object)
     */
    func set(users: [Participant], using api: BreakOut = .shared) -> GroupMessage.Result {
        let body = (users => { $0.id }).json
        return api.doJSONRequest(with: .put, to: .message, arguments: ["id": id], body: body).map { (json: JSON) in
            self.messages = json["messages"].messages
            return self
        }
    }
    
    /**
     Will send a message to the group
     
     - Parameter message: Message
     - Parameter api: Break Out backend
     
     - Returns: Promise of the Group Message Object (will be the same object)
     */
    func send(message: String, using api: BreakOut = .shared) -> GroupMessage.Result {
        let body: JSON = [
            "text": message,
            "date": Date.now.timeIntervalSince1970,
        ]
        return api.doJSONRequest(with: .post,
                                 to: .newMessage,
                                 arguments: ["id": id],
                                 body: body,
                                 acceptableStatusCodes: [200, 201]).flatMap { _ in
                                    
            return self.refresh(using: api)
        }
    }
    
}
