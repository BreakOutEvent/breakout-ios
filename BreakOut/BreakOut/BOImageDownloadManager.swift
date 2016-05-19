//
//  BOImageDownloadManager.swift
//  BreakOut
//
//  Created by Mathias Quintero on 5/19/16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit
import Alamofire

class BOImageDownloadManager {
    
    static let sharedInstance = BOImageDownloadManager()
    
    var cache = [String:BOImage]()
    
    func getImage(url: String, handler: (BOImage) -> ()) {
        if let image = cache[url] {
            handler(image)
        } else {
            Alamofire.request(.GET, url).responseData() { (response) in
                if let data = response.data, image = UIImage(data: data) {
                    let instance = BOImage.createWithImage(image)
                    self.cache[url] = instance
                    handler(instance)
                }
            }
        }
    }
    
}