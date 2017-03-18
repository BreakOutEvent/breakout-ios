//
//  StyleInformation.swift
//  BreakOut
//
//  Created by Leo Käßner on 29.11.15.
//  Copyright © 2015 BreakOut. All rights reserved.
//

import UIKit

extension UIColor {
    
    static var mainOrange: UIColor {
        return UIColor(red: 230.0 / 255.0, green: 130.0 / 255.0, blue: 60.0 / 255.0, alpha: 1.0)
    }
    
    static var lightTransparentWhite: UIColor {
        return UIColor(red:1.0, green:1.0, blue:1.0, alpha:0.5) //For Placeholder Texts
    }
    
    //TODO: @alexkaessner -> Update this information.    
    static var mainBackgroundColor: UIColor {
        return UIColor(red:0.17, green:0.18, blue:0.23, alpha:1)
    }
    
    static var brick: UIColor {
        return UIColor(red: 204 / 255, green: 31 / 355, blue: 31 / 255, alpha: 1)
    }
    
    static var lightBackgroundColor: UIColor {
        return UIColor(red:0.24, green:0.24, blue:0.3, alpha:1)
    }
    
    static var ultraLightBackgroundColor: UIColor {
        return UIColor(red: 244 / 255, green: 244 / 255, blue: 244 / 255, alpha: 1)
    }
    
    static var navigationBarGrey: UIColor {
        return UIColor(red:0.57, green:0.58, blue:0.62, alpha:1)
    }
    
    static var normalButtonColor: UIColor {
        return UIColor(red:0.77, green:0.29, blue:0.96, alpha:1)
    }
    
    static var greyButtonColor: UIColor {
        return UIColor(red:0.57, green:0.58, blue:0.62, alpha:1)
    }
    
    static var barButtonColor: UIColor {
        return UIColor(red:0.57, green:0.58, blue:0.62, alpha:1)
    }
    
    static var graphLineColor: UIColor {
        return UIColor(red:0.77, green:0.29, blue:0.96, alpha:1)
    }
    
    static var graphGradientColor: UIColor {
        return UIColor(red:0.77, green:0.29, blue:0.96, alpha:0.05)
    }
    
    static var normalTextColor: UIColor {
        return UIColor.white
    }
    
}
