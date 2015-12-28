//
//  LoginRegisterViewController.swift
//  BreakOut
//
//  Created by Leo Käßner on 28.12.15.
//  Copyright © 2015 BreakOut. All rights reserved.
//

import UIKit
//import Answers


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
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("email", comment: ""), attributes:[NSForegroundColorAttributeName: Style.lightTransparentWhite])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        //
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
            self.formToLogoConstraint.constant = 20.0
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        //
        self.formContainerViewToBottomConstraint.constant = 0.0
    }
    
    
// MARK: - Button Actions
    
    @IBAction func registerButtonPressed(sender: UIButton) {
        if (self.emailTextField.text == "" || self.passwordTextField.text == ""){
            self.alertPopover.hidden = false
        }
    }
    
    @IBAction func loginButtonPressed(sender: UIButton) {
    }
    
    @IBAction func whatIsBreakOutButtonPressed(sender: UIButton) {
        if let internalWebView = storyboard!.instantiateViewControllerWithIdentifier("internalWebViewController") as? InternalWebViewController {
            presentViewController(internalWebView, animated: true, completion: nil)
            internalWebView.openWebpageWithUrl("http://break-out.org/worum-gehts/")
            
            // --> Tracking
            //Answers.logCustomEventWithName("Opened What-Is-BreakOut", customAttributes: [:])
        }
    }
    
}