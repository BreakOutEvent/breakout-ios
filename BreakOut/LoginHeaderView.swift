//
//  LoginHeaderView.swift
//  BreakOut
//
//  Created by Mathias Quintero on 3/25/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import UIKit

class LoginHeaderView: HeaderView {
    
    @IBOutlet weak var loginButton: UIButton!
    
    static var shared: LoginHeaderView! = {
        guard let nibs = Bundle.main.loadNibNamed("LoginHeaderView", owner: self, options: nil) else {
            return nil
        }
        let headers = nibs.flatMap { $0 as? LoginHeaderView }
        guard let header = headers.first else {
            return nil
        }
        return header
    }()
    
    override var headerHeight: CGFloat {
        return 86
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loginButton.setTitle("welcomeScreenParticipateButtonLoginAndRegister".local, for: .normal)
    }
    
    @IBAction func didPressLogin(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION_PRESENT_LOGIN_SCREEN), object: nil)
    }
    
}
