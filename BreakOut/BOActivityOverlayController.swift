//
//  BOActivityOverlayController.swift
//  BreakOut
//
//  Created by Mathias Quintero on 3/28/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import UIKit
import Sweeft

class BOActivityOverlayController: UIViewController {
    
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var activityIndicator: BOActivityIndicator!
    
    static func create() -> BOActivityOverlayController! {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "BOActivityOverlayController") as? BOActivityOverlayController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let effect = UIBlurEffect(style: .regular)
        let effectView = UIVisualEffectView(effect: effect)
        effectView.clipsToBounds = true
        effectView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.addSubview(effectView)
        effectView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        effectView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        effectView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        effectView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        activityIndicator.startLoading()
    }
    
    func success(completion: @escaping () -> () = dropArguments) {
        activityIndicator.completeLoading(success: true) {
            1.0 >>> {
                self.dismiss(animated: true, completion: completion)
            }
        }
    }
    
    func error(completion: @escaping () -> () = dropArguments) {
        activityIndicator.completeLoading(success: false) {
            1.0 >>> {
                self.dismiss(animated: true, completion: completion)
            }
        }
    }
    
}
