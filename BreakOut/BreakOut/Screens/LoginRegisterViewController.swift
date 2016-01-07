//
//  LoginRegisterViewController.swift
//  BreakOut
//
//  Created by Leo Käßner on 28.12.15.
//  Copyright © 2015 BreakOut. All rights reserved.
//

import UIKit
import Flurry_iOS_SDK

// Networking
import AFNetworking
import AFOAuth2Manager
//import Answers

import MBProgressHUD
import SpinKit


class LoginRegisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var formContainerView: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var whatIsBreakOutButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailUnderlinedView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordUnderlinedView: UIView!
    
    @IBOutlet weak var alertPopover: UIView!
    
    @IBOutlet weak var formContainerViewToBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var formToLogoConstraint: NSLayoutConstraint!
    
    var loadingHUD: MBProgressHUD = MBProgressHUD()
// MARK: - Screen Actions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.loginButton.backgroundColor = Style.mainOrange
        self.loginButton.layer.cornerRadius = 25.0
        
        self.registerButton.backgroundColor = UIColor.whiteColor()
        self.registerButton.alpha = 0.8
        self.registerButton.layer.cornerRadius = 25.0
        
        self.emailTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("email", comment: ""), attributes:[NSForegroundColorAttributeName: Style.lightTransparentWhite])
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("password", comment: ""), attributes:[NSForegroundColorAttributeName: Style.lightTransparentWhite])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        // Tracking
        Flurry.logEvent("/login", withParameters: nil, timed: true)
        
        self.emailTextField.enabled = true
        self.passwordTextField.enabled = true
    }
    
    override func viewDidDisappear(animated: Bool) {
        // Tracking
        Flurry.endTimedEvent("/login", withParameters: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
// MARK: - TextField Functions
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == self.emailTextField {
            // Switch focus to other text field
            self.passwordTextField.becomeFirstResponder()
        }else{
            // Login should be triggered
        }
        return true
    }
    
    
    
// MARK: - Keyboard Functions
    
    func keyboardWillShow(notification: NSNotification) {
        let userInfo:NSDictionary = notification.userInfo!
        if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.formContainerViewToBottomConstraint.constant = keyboardSize.height
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        //
        self.formContainerViewToBottomConstraint.constant = 0.0
    }
    
    
// MARK: - Button Actions
    
    /**
    Checks wether both textfields (E-Mail & Password) are filled in with correct style. If this is ok, the keyboard will be hide and the registration request is started
    
    :param: sender      UIButton which triggers the function
    
    :returns: No return value
    */
    @IBAction func registerButtonPressed(sender: UIButton) {
        if (self.emailTextField.text == "" || self.passwordTextField.text == ""){
            self.alertPopover.alpha = 0.0
            self.alertPopover.hidden = false
            self.formToLogoConstraint.constant = -10.0 // constraint animation needs to be outside animateWithDuration
            UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.alertPopover.alpha = 1.0
                self.view.layoutIfNeeded()
                }, completion: nil)
        }else{
            // Hide Keyboard and start registration procedure
            self.view.endEditing(true)
            self.startRegistrationRequest()
        }
    }
    
    
    @IBAction func loginButtonPressed(sender: UIButton) {
        self.view.endEditing(true)
        self.startLoginRequest()
    }
    
    /**
     Opens the internal WebView to show additional Information which isn't stored in the app.
     
     :param: sender     UIButton which triggers the function
     
     :returns: No return value
     */
    @IBAction func whatIsBreakOutButtonPressed(sender: UIButton) {
        if let internalWebView = storyboard!.instantiateViewControllerWithIdentifier("InternalWebViewController") as? InternalWebViewController {
            presentViewController(internalWebView, animated: true, completion: nil)
            internalWebView.openWebpageWithUrl("http://break-out.org/worum-gehts/")
            
            // --> Tracking
            //Answers.logCustomEventWithName("Opened What-Is-BreakOut", customAttributes: [:])
        }
    }
    
// MARK: - Helper Functions
    func setupLoadingHUD(localizedKey: String) {
        let spinner: RTSpinKitView = RTSpinKitView(style: RTSpinKitViewStyle.StyleChasingDots, color: UIColor.whiteColor(), spinnerSize: 37.0)
        self.loadingHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.loadingHUD.square = true
        self.loadingHUD.mode = MBProgressHUDMode.CustomView
        self.loadingHUD.customView = spinner
        self.loadingHUD.labelText = NSLocalizedString(localizedKey, comment: "loading")
        spinner.startAnimating()
    }
    
    func enableInputs(enabled: Bool) {
        self.emailTextField.enabled = enabled
        self.passwordTextField.enabled = enabled
    }
    
// MARK: - API Requests
    
    /**
    Starts a registration request to the backend-API. It sends the E-Mail and password as a JSON-Body with a POST request tu the '/user/' endpoint of the REST-API.
    If the request is successful, the login function is triggered. In case of an error, the error will be presented to the user in a popover.
    
    :param: No parameters
    
    :returns: No return value
    */
    func startRegistrationRequest() {
        self.setupLoadingHUD("registrationLoading")
        self.enableInputs(false)
        
        let requestManager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager.init(baseURL: NSURL(string: PrivateConstants.backendURL))
        
        let params: NSDictionary = ["email":self.emailTextField.text!, "password":self.passwordTextField.text!]
        
        requestManager.requestSerializer = AFJSONRequestSerializer()
        
        requestManager.POST("user/", parameters: params,
            success: { (operation: AFHTTPRequestOperation, response: AnyObject) -> Void in
                print("Registration Response: ")
                print(response)
                
                // Tracking
                Flurry.logEvent("/registration/completed_successful")
                
                self.loadingHUD.hide(true)
                // Try to Login with new account
                self.startLoginRequest()
            })
            { (operation: AFHTTPRequestOperation?, error:NSError) -> Void in
                print("Registration Error: ")
                print(error)
                
                // TODO: Show detailed errors to the user
                
                self.enableInputs(true)
                self.loadingHUD.hide(true)
                
                // Tracking
                Flurry.logEvent("/registration/completed_error")
        }
    }

    
    /**
     Starts a login request to the backend-API through a OAuth Request. If it is successful, the credentials with accessToken will be send as response.
     
     :param: No parameters
     
     :returns: No return value
     */
    func startLoginRequest() {
        self.setupLoadingHUD("loginLoading")
        self.enableInputs(false)
        
        let oAuthManager: AFOAuth2Manager = AFOAuth2Manager.init(baseURL: NSURL(string: PrivateConstants.backendURL), clientID: "breakout_app", secret: "123456789")
        
        oAuthManager.authenticateUsingOAuthWithURLString("/oauth/token", username: self.emailTextField.text, password: self.passwordTextField.text, scope: "read write",
            success: { (credentials) -> Void in
                print("LOGIN: OAuth Code: "+credentials.accessToken)
                
                //Write login data in UserDefaults
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(self.emailTextField.text, forKey: "userEMail")
                defaults.setObject(credentials.accessToken, forKey: "userAccessToken")
                
                // Empty Textinputs
                self.emailTextField.text = ""
                self.passwordTextField.text = ""
                
                self.loadingHUD.hide(true)
                self.enableInputs(true)
                
                // Tracking
                Flurry.logEvent("/login/completed_successful")
                
                self.dismissViewControllerAnimated(true, completion: nil)
            }) { (error: NSError!) -> Void in
                print("LOGIN: Error: ")
                print(error)
                
                self.enableInputs(true)
                
                // Tracking
                Flurry.logEvent("/login/completed_error")
        }
    }
    
}