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
        
        // Style the navigation bar
        self.navigationController!.navigationBar.translucent = false
        self.navigationController!.navigationBar.barTintColor = Style.mainOrange
        self.navigationController!.navigationBar.backgroundColor = Style.mainOrange
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        self.title = NSLocalizedString("webView", comment: "")
        
        // Create posting button for navigation item
        let rightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: #selector(reloadWebView))
        navigationItem.rightBarButtonItem = rightButton
        
        // Create menu buttons for navigation item
        let barButtonImage = UIImage(named: "menu_Icon_white")
        if barButtonImage != nil {
            self.addLeftBarButtonWithImage(barButtonImage!)
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
    
    func reloadWebView() {
        self.internalWebView.reload()
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