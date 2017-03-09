//
//  PersistentViewController.swift
//  BreakOut
//
//  Created by Mathias Quintero on 3/2/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import UIKit

protocol PersistentViewController {
    static var shared: UIViewController? { get set }
}


extension PersistentViewController {
    
    static func viewController(using viewController: UIViewController) -> UIViewController {
        if let shared = shared {
            return shared
        }
        shared = viewController
        return viewController
    }
    
}
