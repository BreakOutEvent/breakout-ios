//
//  BOObject.swift
//  BreakOut
//
//  Created by Mathias Quintero on 11/26/16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import SwiftyJSON
import Sweeft

protocol BOObject: class {
    
    static var items: [Int : Self] { get set }
    
    var uuid: Int { get }
    var json: JSON { get }
    
    init?(from json: JSON)
    
}

extension BOObject {
    
    static var all: [Self] {
        return items.map { $1 }
    }
    
    static func all(matching handler: (Self) -> Bool) -> [Self] {
        return all |> handler
    }
    
    static func first(matching handler: (Self) -> Bool) -> Self? {
        return all(matching: handler).first
    }
    
    static func array(from json: JSON) -> [Self]? {
        guard let array = json.array else {
            return nil
        }
        return !(array => Self.create)
    }
    
    static func item(with uuid: Int) -> Self? {
        return items[uuid]
    }
    
    static func create(from json: JSON) -> Self? {
        guard let id = json["id"].int else {
            return nil
        }
        if let item = Self.item(with: id) {
            return item
        }
        let item = Self.init(from: json)
        item?.save()
        return item
    }
    
    func save() {
        Self.items[self.uuid] = self
    }
    
}
