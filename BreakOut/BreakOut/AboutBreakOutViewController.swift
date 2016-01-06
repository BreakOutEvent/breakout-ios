//
//  SecondViewController.swift
//  BreakOut
//
//  Created by Leo Käßner on 14.08.15.
//  Copyright (c) 2015 BreakOut. All rights reserved.
//

import UIKit

import Flurry_iOS_SDK

class AboutBreakOutViewController: UIViewController {
    
    @IBOutlet weak var internalWebView: UIWebView!
    var initialURL: String = "http://www.break-out.org"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let url = NSURL (string: self.initialURL)
        let requestObj = NSURLRequest(URL: url!)
        self.internalWebView.loadRequest(requestObj)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        // Tracking
        Flurry.logEvent("/aboutBreakOutView", withParameters: ["url":self.initialURL], timed: true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        // Tracking
        Flurry.endTimedEvent("/aboutBreakOutView", withParameters: nil)
    }


}

