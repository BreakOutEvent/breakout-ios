//
//  InternalWebViewController.swift
//  BreakOut
//
//  Created by Leo Käßner on 28.12.15.
//  Copyright © 2015 BreakOut. All rights reserved.
//

import UIKit


class InternalWebViewController: UIViewController {
    
    @IBOutlet weak var internalWebView: UIWebView!
    
// MARK: - Screen Actions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        //
    }
    
    func openWebpageWithUrl(urlString: String) {
        let url = NSURL (string: urlString)
        let requestObj = NSURLRequest(URL: url!)
        self.internalWebView.loadRequest(requestObj)
    }
    
// MARK: Button Actions
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            //Code?!
        }
    }
}