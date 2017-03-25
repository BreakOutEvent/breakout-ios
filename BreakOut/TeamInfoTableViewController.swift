//
//  TeamInfoTableViewController.swift
//  BreakOut
//
//  Created by Mathias Quintero on 3/14/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import Sweeft
import UIKit

class TeamInfoTableViewController: UITableViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var participantsLabel: UILabel!
    @IBOutlet weak var statsLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var teamProfileController: TeamViewController?
    
    var team: Team? {
        return teamProfileController?.team
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 500
        
        imageView.layer.cornerRadius = imageView.frame.height / 2
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        imageView.clipsToBounds = true
        
        teamProfileController?.onChange { _ in
            self.load()
        }
        load()
    }
    
    func load() {
        imageView.image = team?.image?.image ?? UIImage(named: "breakoutDefaultBackground_600x600")
        nameLabel.text = team?.name
        participantsLabel.text = team?.names.join(with: ", ") { "\($0.firstname) \($0.lastname)" }
        if let distance = team?.distance, let money = team?.sum {
            statsLabel.text = "\(Int(distance)) km | \(String(format: "%.2f €", money))"
        }
        descriptionLabel.text = team?.description
        var image = team?.image
        image?.onChange(do: **self.load)
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            cell.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, cell.bounds.size.width)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}
