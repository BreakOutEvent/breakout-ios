//
//  TeamHeaderView.swift
//  BreakOut
//
//  Created by Mathias Quintero on 3/14/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import UIKit

class TeamHeaderView: UIView {

    @IBOutlet weak var profilePicView: UIImageView!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var namesLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton! {
        didSet {
            actionButton.imageView?.set(color: .white)
        }
    }
    
    var onClick: () -> () = {}
    
    func use(team: Team) {
//        actionButton.imageView?.image = #imageLiteral(resourceName: "back_icon_std")
        
        profilePicView.image = team.image?.image ?? UIImage(named: "breakoutDefaultBackground_600x600")
        teamNameLabel.text = "#\(team.id) \(team.name)"
        namesLabel.text = team.names.join(with: ", ") { $0.firstname }
        if let distance = team.distance, let money = team.sum {
            distanceLabel.text = "\(Int(distance)) km"
            moneyLabel.text = String(format: "%.2f €", money)
        } else {
            distanceLabel.text = ""
            moneyLabel.text = ""
        }
    }
    
    static func create(for team: Team?, image: UIImage = #imageLiteral(resourceName: "back_icon_std"), onClick: @escaping () -> () = {}) -> TeamHeaderView! {
        guard let nibs = Bundle.main.loadNibNamed("TeamHeaderView", owner: self, options: nil) else {
            return nil
        }
        let headers = nibs.flatMap { $0 as? TeamHeaderView }
        guard let header = headers.first else {
            return nil
        }
        header.actionButton.setImage(image, for: .normal)
        header.onClick = onClick
        if let team = team {
            header.use(team: team)
        } else {
            header.profilePicView.image = UIImage(named: "breakoutDefaultBackground_600x600")
        }
        return header
    }
    
    @IBAction func didPressActionButton(_ sender: Any) {
        onClick()
    }
    
}
