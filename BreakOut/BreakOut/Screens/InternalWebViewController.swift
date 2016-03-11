//
//  InternalWebViewController.swift
//  BreakOut
//
//  Created by Leo Käßner on 28.12.15.
//  Copyright © 2015 BreakOut. All rights reserved.
//

import UIKit
import Flurry_iOS_SDK


class InternalWebViewController: UIViewController {
    
    @IBOutlet weak var internalWebView: UIWebView!
    
    var initialURL: String = "http://www.break-out.org"
    var urlToOpenAfterViewDidLoad: String?
    
// MARK: - Screen Actions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if self.urlToOpenAfterViewDidLoad != nil {
            self.openWebpageWithUrl(urlToOpenAfterViewDidLoad!)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        // Tracking
        Flurry.logEvent("/internalWebView", withParameters: ["url":self.initialURL], timed: true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        // Tracking
        Flurry.endTimedEvent("/internalWebView", withParameters: nil)
    }
    
    func openWebpageWithUrl(urlString: String) {
        self.initialURL = urlString
        
        let url = NSURL (string: urlString)
        let requestObj = NSURLRequest(URL: url!)
        
        if self.internalWebView != nil {
            self.internalWebView.loadRequest(requestObj)
        }else{
            self.urlToOpenAfterViewDidLoad = urlString
        }
    }
    
// MARK: Button Actions
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            //Code?!
        }
    }
}