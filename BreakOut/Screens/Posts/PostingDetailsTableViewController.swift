 //
//  PostingDetailsTableViewController.swift
//  BreakOut
//
//  Created by Leo Käßner on 14.05.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit
import Sweeft

import Crashlytics

class PostingDetailsTableViewController: UITableViewController {
    
    var postingID: Int = Int()
    
    var posting: Post! {
        didSet {
            posting >>> **self.tableView.reloadData
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "postingDetailsTitle".local
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .ultraLightBackgroundColor
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 175.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.alpha = 1.0
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        posting.media ==> { $0.video } => { $0.pause() }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return posting.comments.count
        case 2:
            if CurrentUser.shared.isLoggedIn() {
                return 1
            } else {
                return 0
            }
        default:
            return 0
        }
    }
    
    func configureCommentCell(_ cell: PostingCommentTableViewCell, indexPath: IndexPath) {
        let comment = posting.comments[indexPath.row]
        cell.teamNameLabel.text = comment.participant.name
        cell.timestampLabel.text = comment.date.toString()
        cell.commentMessageLabel.text = comment.text ?? ""
        cell.teamPictureImageView.image = comment.participant.image?.image ?? UIImage(named: "emptyProfilePic")
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
    }
    
    func configurePostingCell(_ cell: PostingTableViewCell) {
        cell.posting = posting
        cell.parentTableViewController = self
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? PostingTableViewCell {
            cell.loadInterface()
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostingTableViewCell", for: indexPath) as! PostingTableViewCell
            configurePostingCell(cell)
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostingCommentTableViewCell", for: indexPath) as! PostingCommentTableViewCell
            configureCommentCell(cell, indexPath: indexPath)
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostingCommentInputTableViewCell", for: indexPath)
            if let c = cell as? PostingCommentInputTableViewCell {
                c.post = posting
                c.reloadHandler = tableView.reloadData
            }
            return cell
        } else {
            let cell = UITableViewCell()
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section != 0
    }

}
