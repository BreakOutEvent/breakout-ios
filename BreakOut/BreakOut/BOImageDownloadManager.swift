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
    
    func getImage(id: Int, url: String, handler: (BOImage) -> ()) {
        if let arrayOfImages = BOImage.MR_findByAttribute("uid", withValue: id) as? Array<BOImage>, image = arrayOfImages.first {
            handler(image)
        } else {
            Alamofire.request(.GET, url).responseData() { (response) in
                if let data = response.data, image = UIImage(data: data) {
                    let instance = BOImage.createWithImage(image)
                    handler(instance)
                }
            }
        }
    }
    
}