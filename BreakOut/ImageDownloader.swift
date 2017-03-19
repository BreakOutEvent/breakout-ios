//
//  ImageDownloader.swift
//  BreakOut
//
//  Created by Mathias Quintero on 3/18/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import Sweeft
import UIKit

class ImageDownloader {
    
    static var cache = [String : Promise<UIImage, AnyError>]()
    
    static func download(from url: URL) -> Promise<UIImage, AnyError> {
        guard let cached = cache[url.absoluteString] else {
            let promise: Promise<UIImage, AnyError> = async(qos: .userInitiated) {
                guard let data = try? Data(contentsOf: url) else {
                    throw APIError.noData
                }
                guard let image = UIImage(data: data) else {
                    throw APIError.invalidData(data: data)
                }
                return image
            }
            cache[url.absoluteString] = promise
            return promise
        }
        return cached
    }
    
}
