//
//  BOImageDownloadManager.swift
//  BreakOut
//
//  Created by Mathias Quintero on 5/19/16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit
import Alamofire

import Crashlytics

class BOImageDownloadManager {
    
    static let shared = BOImageDownloadManager()
    
    func getImage(_ id: Int, url: String, handler: @escaping (BOMedia) -> ()) {
        Alamofire.request(url).responseData() { (response) in
            if let data = response.data, let image = UIImage(data: data) {
                let instance = BOMedia(from: image)
                handler(instance)
                
                Answers.logCustomEvent(withName: "/BOImageDownloadManager/", customAttributes: ["Successful":response.result.isSuccess.description, "Request Duration": response.timeline.requestDuration.description])
            }
        }
    }
    
    func getBetterImage(_ id: Int) {
//        if let arrayOfImages = BOImage.mr_find(byAttribute: "uid", withValue: id) as? Array<BOImage>, let image = arrayOfImages.first, let url = image.betterDownloadUrl {
//            Alamofire.request(url).responseData() { (response) in
//                if let data = response.data, let img = UIImage(data: data) {
//                    image.writeImage(img)
//                    image.needsBetterDownload = false
//                    image.save()
//                    Answers.logCustomEvent(withName: "/BOImageDownloadManager/", customAttributes: ["Successful":response.result.isSuccess.description, "Request Duration": response.timeline.requestDuration.description])
//                }
//            }
//        }
    }
    
}
