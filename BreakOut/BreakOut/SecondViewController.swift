//
//  SecondViewController.swift
//  BreakOut
//
//  Created by Leo Käßner on 14.08.15.
//  Copyright (c) 2015 BreakOut. All rights reserved.
//

import UIKit
import SDWebImage

class SecondViewController: UIViewController {

    @IBOutlet weak var testImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // The following code is the test for image caching with SDWebImage Framework
        let block: SDWebImageCompletionBlock! = {(image: UIImage!, error: NSError!, cacheType: SDImageCacheType!, imageURL: NSURL!) -> Void in
            //print("SDWebImageTest: "+self)
            print(image)
        }
        let url = NSURL(string: "https://placehold.it/350x150")
        self.testImageView.sd_setImageWithURL(url, completed: block)
        // End of test code
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

