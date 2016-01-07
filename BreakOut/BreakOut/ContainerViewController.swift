//
//  ContainerViewController.swift
//  BreakOut
//
//  Created by Leo Käßner on 03.01.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit

import SlideMenuControllerSwift

class ContainerViewController: SlideMenuController {
    
    override func awakeFromNib() {
        if let controller = self.storyboard?.instantiateViewControllerWithIdentifier("UserProfileTableViewController") {
            self.mainViewController = controller
        }
        if let controller = self.storyboard?.instantiateViewControllerWithIdentifier("SidebarMenuTableViewController") {
            self.leftViewController = controller
        }
        
        SlideMenuOptions.contentViewScale = 1.0
        
        super.awakeFromNib()
    }

}
