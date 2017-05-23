//
//  TeamCollectionViewCell.swift
//  BreakOut
//
//  Created by Mathias Quintero on 3/15/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import UIKit

class TeamCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statsLabel: UILabel!
    
    var team: Team! {
        didSet {
            imageView.image = team.image?.image ?? #imageLiteral(resourceName: "emptyProfilePic")
            nameLabel.text = team.name
            statsLabel.text = team.names.join(with: ", ") { $0.firstname }
//            if let distance = team.distance, let money = team.sum {
//                statsLabel.text = "\(Int(distance)) km | \(String(format: "%.2f €", money))"
//            } else {
//                statsLabel.text = ""
//            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.clipsToBounds = true
    }
    
}
