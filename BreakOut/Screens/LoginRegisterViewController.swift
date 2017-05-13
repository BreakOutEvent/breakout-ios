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

import SpinKit

import Toaster

import Sweeft


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

// MARK: - Screen Actions    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        
        self.loginButton.backgroundColor = .mainOrange
        self.loginButton.layer.cornerRadius = 25.0
        
        self.registerButton.backgroundColor = UIColor.white
        self.registerButton.alpha = 0.8
        self.registerButton.layer.cornerRadius = 25.0
        
        self.emailTextField.attributedPlaceholder = .localized("email", with: .lightTransparentWhite)
        self.passwordTextField.attributedPlaceholder = .localized("password", with: .lightTransparentWhite)
        
        // Set localized Button titles
        self.loginButton.setTitle("login".local, for: .normal)
        self.registerButton.setTitle("register".local, for: .normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Tracking
        Flurry.logEvent("/login", withParameters: nil, timed: true)
        
        self.emailTextField.isEnabled = true
        self.passwordTextField.isEnabled = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // Tracking
        Flurry.endTimedEvent("/login", withParameters: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        NotificationCenter.default.addObserver(self, selector: #selector(LoginRegisterViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginRegisterViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - TextField Functions
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == self.emailTextField {
            // Switch focus to other text field
            self.passwordTextField.becomeFirstResponder()
        } else {
            // Login should be triggered
            self.loginButtonPressed(loginButton)
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.alertPopover.isHidden = true
            self.alertPopover.alpha = 0.0
            self.view.layoutIfNeeded()
        }, completion: nil)
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let underlay = textField == emailTextField ? emailUnderlinedView : passwordUnderlinedView
        UIView.animate(withDuration: 0.3) {
            underlay?.backgroundColor = .mainOrange
            underlay?.alpha = 1.0
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let underlay = textField == emailTextField ? emailUnderlinedView : passwordUnderlinedView
        UIView.animate(withDuration: 0.3) {
            underlay?.backgroundColor = .white
            underlay?.alpha = 0.5
        }
    }
    
    
    
// MARK: - Keyboard Functions
    
    func keyboardWillShow(_ notification: Notification) {
        let userInfo:NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardIsResizing(to: keyboardSize.height, notification: notification)
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        keyboardIsResizing(to: 0, notification: notification)
    }
    
    func keyboardIsResizing(to height: CGFloat, notification: Notification) {
        guard let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double,
            let curveValue = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt else {
                
            return
        }
        let curve = UIViewAnimationOptions(rawValue: curveValue << 16)
        UIView.animate(withDuration: duration, delay: 0.0, options: curve, animations: {
            self.view.layoutIfNeeded()
            self.formContainerViewToBottomConstraint.constant = height
            self.logoBottomConstraint.constant = max(16, 55 - height)
            self.logoTopConstraint.constant = max(16, 60 - height)
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    
// MARK: - Button Actions
    
    /**
    Checks wether both textfields (E-Mail & Password) are filled in with correct . If this is ok, the keyboard will be hide and the registration request is started
    
    :param: sender      UIButton which triggers the function
    
    :returns: No return value
    */
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        if self.allInputsAreFilledOut() {
            // Hide Keyboard and start registration procedure
            self.view.endEditing(true)
            self.startRegistrationRequest()
        }
    }
    
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        if self.allInputsAreFilledOut() {
            self.view.endEditing(true)
            self.startLoginRequest()
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /**
     Opens the internal WebView to show additional Information which isn't stored in the app.
     
     :param: sender     UIButton which triggers the function
     
     :returns: No return value
     */
    @IBAction func whatIsBreakOutButtonPressed(_ sender: UIButton) {
        if let internalWebView = storyboard!.instantiateViewController(withIdentifier: "InternalWebViewController") as? InternalWebViewController {
            let navigationController = UINavigationController(rootViewController: internalWebView)
            
            present(navigationController, animated: true, completion: nil)
            internalWebView.openWebpageWithUrl("https://break-out.org/next-steps")
            
            // --> Tracking
            //Answers.logCustomEventWithName("Opened What-Is-BreakOut", customAttributes: [:])
        }
    }
    
// MARK: - Helper Functions
    func allInputsAreFilledOut() -> Bool {
        if (self.emailTextField.text == "" || self.passwordTextField.text == ""){
            self.alertPopover.alpha = 0.0
            self.alertPopover.isHidden = false
            self.formToLogoConstraint.constant = -10.0 // constraint animation needs to be outside animateWithDuration
            UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.alertPopover.alpha = 1.0
                self.view.layoutIfNeeded()
            }, completion: nil)
            return false
        }
        
        return true
    }
    
    func enableInputs(_ enabled: Bool) {
        self.emailTextField.isEnabled = enabled
        self.passwordTextField.isEnabled = enabled
    }
    
// MARK: - API Requests
    
    /**
    Starts a registration request to the backend-API. It sends the E-Mail and password as a JSON-Body with a POST request tu the '/user/' endpoint of the REST-API.
    If the request is successful, the login function is triggered. In case of an error, the error will be presented to the user in a popover.
    
    :param: No parameters
    
    :returns: No return value
    */
    func startRegistrationRequest() {
        self.enableInputs(false)
        let activity = BOActivityOverlayController.create()
        activity?.modalTransitionStyle = .crossDissolve
        self.present(activity!, animated: true) {
            CurrentUser.shared.register(email: self.emailTextField.text.?, password: self.passwordTextField.text.?).onSuccess { _ in
                // Tracking
                Flurry.logEvent("/registration/completed_successful")
                Answers.logSignUp(withMethod: "e-mail",
                                  success: true,
                                  customAttributes: [:])
                
                self.startLoginRequest(overlay: activity)
            }
            .onError { error in
                
                self.enableInputs(true)
                activity?.error {
                    switch error {
                    case .invalidStatus(409, _):
                        print("Email already exists")
                    default: break
                    }
                }
                
                // Tracking
                Flurry.logEvent("/registration/completed_error")
                Answers.logSignUp(withMethod: "e-mail",
                                  success: false,
                                  customAttributes: [:])
            }
        }
        
        
    }
    
    func storeCredentials(email: String, pass: String) {
        let loginDetails = [
            AppExtensionTitleKey: "BreakOut",
            AppExtensionUsernameKey: email,
            AppExtensionPasswordKey: pass,
        ]
//        OnePasswordExtension.shared().storeLogin(forURLString: "https://break-out.org/",
//                                                 loginDetails: loginDetails,
//                                                 passwordGenerationOptions: nil,
//                                                 for: self,
//                                                 sender: self,
//                                                 completion: dropArguments)
    }

    
    /**
     Starts a login request to the backend-API through a OAuth Request. If it is successful, the credentials with accessToken will be send as response.
     
     :param: No parameters
     
     :returns: No return value
     */
    func startLoginRequest(overlay: BOActivityOverlayController? = nil) {
        if let email = emailTextField.text, let pass = passwordTextField.text {
            storeCredentials(email: email, pass: pass)
            let activity = overlay ?? BOActivityOverlayController.create()
            self.enableInputs(false)
            let doit = { () -> () in
                BreakOut.shared.login(email: email, password: pass).onSuccess { _ in
                    CurrentUser.get().onSuccess { user in
                        // Empty Textinputs
                        self.emailTextField.text = ""
                        self.passwordTextField.text = ""
                        
                        self.enableInputs(true)
                        
                        // Tracking
                        Flurry.logEvent("/login/completed_successful")
                        Answers.logLogin(withMethod: "e-mail", success: true, customAttributes: [:])
                        
                        activity?.success {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
                .onError { error in
                    activity?.error {
                        switch error {
                        case .invalidStatus(401, let data):
                            print("Incorrect credentials")
                            print("Data: \(data?.string ?? "")")
                        default:
                            break
                        }
                    }
                    self.enableInputs(true)
                }
            }
            if overlay == nil {
                activity?.modalTransitionStyle = .crossDissolve
                self.present(activity!, animated: true, completion: doit)
            } else {
                doit()
            }
            
        } else {
            //TODO: Handle no text entered
        }
        
    }
    
    @IBAction func useOnePassword(_ sender: Any) {
        OnePasswordExtension.shared().findLogin(forURLString: "https://break-out.org", for: self, sender: self) { (dict, error) in
            guard let dict = dict, dict.count > 0 else {
                return
            }
            self.emailTextField.text = dict[AppExtensionUsernameKey] as? String
            self.passwordTextField.text = dict[AppExtensionPasswordKey] as? String
        }
    }
}
