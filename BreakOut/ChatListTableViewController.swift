//
//  ChatListTableViewController.swift
//  BreakOut
//
//  Created by Mathias Quintero on 3/27/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import UIKit

class ChatListTableViewController: UITableViewController {
    
    var chats = [GroupMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Chat"
        self.navigationController!.navigationBar.isTranslucent = false
        self.navigationController!.navigationBar.barTintColor = .mainOrange
        self.navigationController!.navigationBar.backgroundColor = .mainOrange
        self.navigationController!.navigationBar.tintColor = UIColor.white
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        // Create menu buttons for navigation item
        let barButtonImage = UIImage(named: "menu_Icon_white")
        if barButtonImage != nil {
            self.addLeftBarButtonWithImage(barButtonImage!)
        }
        
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = .mainOrange
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: UIControlEvents.valueChanged)
        
        loadMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func loadMessages() {
        GroupMessage.all().onSuccess { chats in
            self.chats = chats.sorted(descending: { $0.lastActivity ?? Date.distantPast })
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chat", for: indexPath)
        if let cell = cell as? ChatTableViewCell {
            cell.message = chats[indexPath.row]
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let controller = storyboard.instantiateViewController(withIdentifier: "ChatViewController")
        
        if let controller = controller as? ChatViewController {
            controller.chat = chats[indexPath.row]
        }
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func handleRefresh(_ refreshControll: UIRefreshControl) {
        loadMessages()
    }
    
    @IBAction func compose(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let controller = storyboard.instantiateViewController(withIdentifier: "ChatViewController")
        
        if let controller = controller as? ChatViewController {
            controller.chat = chats[0]
        }
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
}