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
    
    
    func use(team: Team) {
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
    
    static func create(for team: Team?) -> TeamHeaderView! {
        guard let nibs = Bundle.main.loadNibNamed("TeamHeaderView", owner: self, options: nil) else {
            return nil
        }
        let headers = nibs.flatMap { $0 as? TeamHeaderView }
        guard let header = headers.first else {
            return nil
        }
        if let team = team {
            header.use(team: team)
        }
        return header
    }
    
}
