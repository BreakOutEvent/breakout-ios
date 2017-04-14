//
//  Event.swift
//  BreakOut
//
//  Created by Mathias Quintero on 2/25/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import Sweeft

/// Representation of an Event
struct Event {
    let id: Int
    let title: String
    let city: String
    let date: Date
    let isCurrent: Bool
}

extension Event: Deserializable {
    
    public init?(from json: JSON) {
        guard let id = json["id"].int,
            let title = json["title"].string,
            let city = json["city"].string,
            let date = json["date"].date() else {
                
                return nil
        }
        self.init(id: id, title: title, city: city, date: date, isCurrent: json["current"].bool ?? true)
    }
    
}

extension Event {
    
    /**
     Fetch all Teams participating in the Event
     
     - Parameter api: Break Out backend
     
     - Returns: Promise of the locations
     */
    func teams(using api: BreakOut = .shared) -> Team.Results {
        return Team.all(for: id, using: api)
    }
    
}

extension Event {
    
    /**
     Fetch all Events
     
     - Parameter api: Break Out backend
     
     - Returns: Promise of the locations
     */
    static func all(using api: BreakOut = .shared) -> Event.Results {
        return getAll(using: api, at: .event)
    }
    
    /**
     Fetch all Events that are marked as a current event
     
     - Parameter api: Break Out backend
     
     - Returns: Promise of the locations
     */
    static func current(using api: BreakOut = .shared) -> Event.Results {
        return all().nested { $0 |> { $0.isCurrent } }
    }
    
    /**
     Fetch the ID of the current event
     
     - Parameter api: Break Out backend
     
     - Returns: Promise of the locations
     */
    static func currentId(using api: BreakOut = .shared) -> Promise<Int, APIError> {
        let event = CurrentUser.shared.currentEventId()
        if event > -1 {
            return .successful(with: event)
        }
        return current(using: api).nested { events, promise in
            guard let last = events.first?.id else {
                return promise.error(with: .noData)
            }
            promise.success(with: last)
        }
    }
    
}
