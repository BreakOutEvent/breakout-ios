//
//  TeamProfilePostingsTableViewController.swift
//  BreakOut
//
//  Created by Leo Käßner on 05.02.16.
//  Copyright © 2016 BreakOut. All rights reserved.
//

import UIKit
import Sweeft
import MXParallaxHeader

class TeamProfilePostingsTableViewController: UITableViewController {
    
    weak var teamProfileController: TeamViewController?
    
    var team: Team? {
        return teamProfileController?.team
    }
    
    var posts = [Post]()

    override func viewDidLoad() {
        super.viewDidLoad()
        extendedLayoutIncludesOpaqueBars = true
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 175.0
        tableView.parallaxHeader.height = 300
        tableView.parallaxHeader.mode = .fill
        let barHeight = teamProfileController?.navigationController?.navigationBar.frame.height ?? 0
        let menuHeight = teamProfileController?.subMenu.frame.height ?? 0
        tableView.parallaxHeader.minimumHeight = barHeight + menuHeight + UIApplication.shared.statusBarFrame.height
        teamProfileController?.onChange { _ in
            self.load()
        }
        load()
    }
    
    func setImage() {
        var profilePic = team?.image
        profilePic?.onChange { _ in
            self.setImage()
        }
        tableView.parallaxHeader.view = TeamHeaderView.create(for: team)
    }
    
    func load() {
        setImage()
        team?.posts().onSuccess { posts in
            self.posts = posts
            posts >>> **self.tableView.reloadData
            self.tableView.reloadData()
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        teamProfileController?.hasScrolled(to: offset)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostingTableViewCell", for: indexPath)
        if let cell = cell as? PostingTableViewCell {
            cell.posting = posts[indexPath.row]
            cell.parentTableViewController = self
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let postingDetailsTableViewController: PostingDetailsTableViewController = storyboard.instantiateViewController(withIdentifier: "PostingDetailsTableViewController") as! PostingDetailsTableViewController
        
        postingDetailsTableViewController.posting = posts[indexPath.row]
        teamProfileController?.navigationController?.navigationBar.alpha = 1.0
        teamProfileController?.navigationController?.pushViewController(postingDetailsTableViewController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? PostingTableViewCell {
            cell.video?.pause() // Pause video when you're not it's not on screen
        }
    }

}
