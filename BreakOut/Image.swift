//
//  Image.swift
//  BreakOut
//
//  Created by Mathias Quintero on 2/25/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import Sweeft
import UIKit

/// Image
final class Image: Observable {
    
    var listeners = [Listener]()
    let id: Int
    let isEmpty: Bool
    
    var image: UIImage? {
        didSet {
            hasChanged()
        }
    }
    
    init(id: Int, image: UIImage) {
        self.id = id
        self.image = image
        self.isEmpty = false
    }
    
    init(id: Int, url: String?) {
        self.id = id
        isEmpty = url == nil
        if let url = url {
            UIImage.at(url: url).onSuccess { image in
                self.image = image
            }
        }
    }
    
}

extension Image: Deserializable {
    
    convenience init?(from json: JSON, height: Int) {
        let sizes = json["sizes"].array |> { $0.type == .image }
        let fit = sizes |> { $0.isFitFor(height: height) }
        guard let id = json["id"].int else {
                
            return nil
        }
        let size = fit.first ?? sizes.last
        self.init(id: id, url: size?["url"].string)
    }
    
    convenience init?(from json: JSON) {
        let deviceHeight = Int(UIScreen.main.bounds.height)
        self.init(from: json, height: deviceHeight)
    }
    
}
