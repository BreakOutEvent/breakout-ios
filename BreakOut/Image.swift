//
//  Image.swift
//  BreakOut
//
//  Created by Mathias Quintero on 2/25/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import Sweeft
import UIKit

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
    
    convenience init?(from json: JSON, height: Int) {
        guard let id = json["id"].int else {
            return nil
        }
        let deviceWidth = UIScreen.main.bounds.width
        print(deviceWidth)
        let sizes = json["sizes"].array |> { $0.type == .image } |> { $0.isFitFor(height: height) }
        let size = sizes.first ?? json["sizes"].array?.last
        self.init(id: id, url: size?["url"].string)
    }
    
    convenience init?(from json: JSON) {
        let deviceHeight = Int(UIScreen.main.bounds.height)
        self.init(from: json, height: deviceHeight)
    }
    
}
