//
//  LoginRegisterViewController.swift
//  BreakOut
//
//  Created by Leo Käßner on 28.12.15.
//  Copyright © 2015 BreakOut. All rights reserved.
//

import UIKit
import Flurry_iOS_SDK
import Crashlytics

// Networking
import AFNetworking
import AFOAuth2Manager
//import Answers

import MBProgressHUD
import SpinKit

import JLToast


class LoginRegisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var logoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoBottomConstraint: NSLayoutConstraint!
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
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        
        self.loginButton.backgroundColor = Style.mainOrange
        self.loginButton.layer.cornerRadius = 25.0
        
        self.registerButton.backgroundColor = UIColor.whiteColor()
        self.registerButton.alpha = 0.8
        self.registerButton.layer.cornerRadius = 25.0
        
        self.emailTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("email", comment: ""), attributes:[NSForegroundColorAttributeName: Style.lightTransparentWhite])
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("password", comment: ""), attributes:[NSForegroundColorAttributeName: Style.lightTransparentWhite])
        
        // Set localized Button titles
        self.loginButton.setTitle(NSLocalizedString("login", comment: ""), forState: UIControlState.Normal)
        self.registerButton.setTitle(NSLocalizedString("register", comment: ""), forState: UIControlState.Normal)
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
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
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
            self.logoBottomConstraint.constant = 5.0
            self.logoTopConstraint.constant = 5.0
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        //
        self.formContainerViewToBottomConstraint.constant = 0.0
        self.logoBottomConstraint.constant = 55.0
        self.logoTopConstraint.constant = 60.0
    }
    
    
// MARK: - Button Actions
    
    /**
    Checks wether both textfields (E-Mail & Password) are filled in with correct style. If this is ok, the keyboard will be hide and the registration request is started
    
    :param: sender      UIButton which triggers the function
    
    :returns: No return value
    */
    @IBAction func registerButtonPressed(sender: UIButton) {
        if self.allInputsAreFilledOut() {
            // Hide Keyboard and start registration procedure
            self.view.endEditing(true)
            self.startRegistrationRequest()
        }
    }
    
    
    @IBAction func loginButtonPressed(sender: UIButton) {
        if self.allInputsAreFilledOut() {
            self.view.endEditing(true)
            self.startLoginRequest()
        }
    }
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     Opens the internal WebView to show additional Information which isn't stored in the app.
     
     :param: sender     UIButton which triggers the function
     
     :returns: No return value
     */
    @IBAction func whatIsBreakOutButtonPressed(sender: UIButton) {
        if let internalWebView = storyboard!.instantiateViewControllerWithIdentifier("InternalWebViewController") as? InternalWebViewController {
            let navigationController = UINavigationController(rootViewController: internalWebView)
            
            presentViewController(navigationController, animated: true, completion: nil)
            internalWebView.openWebpageWithUrl("http://break-out.org/worum-gehts/")
            
            // --> Tracking
            //Answers.logCustomEventWithName("Opened What-Is-BreakOut", customAttributes: [:])
        }
    }
    
// MARK: - Helper Functions
    func allInputsAreFilledOut() -> Bool {
        if (self.emailTextField.text == "" || self.passwordTextField.text == ""){
            self.alertPopover.alpha = 0.0
            self.alertPopover.hidden = false
            self.formToLogoConstraint.constant = -10.0 // constraint animation needs to be outside animateWithDuration
            UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.alertPopover.alpha = 1.0
                self.view.layoutIfNeeded()
                }, completion: nil)
            return false
        }
        
        return true
    }
        
    func setupLoadingHUD(localizedKey: String) {
        let spinner: RTSpinKitView = RTSpinKitView(style: RTSpinKitViewStyle.Style9CubeGrid, color: UIColor.whiteColor(), spinnerSize: 37.0)
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
        
        let params: NSDictionary = ["email":self.emailTextField.text!, "password":self.passwordTextField.text!]
        
        BONetworkManager.doJSONRequestPOST(.User, arguments: [], parameters: params, auth: false, success: { (response) in
            let userID = response.valueForKey("id")
            CurrentUser.sharedInstance.userid = userID as? Int
            CurrentUser.sharedInstance.email = self.emailTextField.text
            CurrentUser.sharedInstance.storeInNSUserDefaults()
            
            // Tracking
            Flurry.logEvent("/registration/completed_successful")
            Answers.logSignUpWithMethod("e-mail",
                success: true,
                customAttributes: [:])
            
            self.loadingHUD.hide(true)
            // Try to Login with new account
            self.startLoginRequest()

        }) { (error, response) in
            // TODO: Show detailed errors to the user
            
            self.enableInputs(true)
            self.loadingHUD.hide(true)
            
            // Tracking
            Flurry.logEvent("/registration/completed_error")
            Answers.logSignUpWithMethod("e-mail",
                                        success: false,
                                        customAttributes: [:])
        }
    }

    
    /**
     Starts a login request to the backend-API through a OAuth Request. If it is successful, the credentials with accessToken will be send as response.
     
     :param: No parameters
     
     :returns: No return value
     */
    func startLoginRequest() {
        
        if let email = emailTextField.text, pass = passwordTextField.text {
            self.setupLoadingHUD("loginLoading")
            self.enableInputs(false)
            
            BONetworkManager.loginRequest(email, pass: pass, success: { () in
                
                BONetworkManager.doJSONRequestGET(.CurrentUser, arguments: [], parameters: nil, auth: true, success: { (response) in
                    CurrentUser.resetUser()
                    CurrentUser.sharedInstance.setAttributesWithJSON(response as! NSDictionary)
                    CurrentUser.sharedInstance.storeInNSUserDefaults()
                    
                    // Empty Textinputs
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                    
                    self.loadingHUD.hide(true)
                    self.enableInputs(true)
                    
                    // Tracking
                    Flurry.logEvent("/login/completed_successful")
                    Answers.logLoginWithMethod("e-mail", success: true, customAttributes: [:])
                    
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
                
            }, error:
            { () in
                self.loadingHUD.hide(true)
                self.enableInputs(true)
            })
        } else {
            //TODO: Handle no text entered
        }
        
    }
    
}