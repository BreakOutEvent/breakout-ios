//
//  ChatListTableViewController.swift
//  BreakOut
//
//  Created by Mathias Quintero on 3/27/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import UIKit
import Sweeft

class ChatListTableViewController: UITableViewController {
    
    var chats = [GroupMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Chat"
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = .mainOrange
        self.navigationController?.navigationBar.backgroundColor = .mainOrange
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        // Create menu buttons for navigation item
        let barButtonImage = UIImage(named: "menu_Icon_white")
        if barButtonImage != nil {
            self.addLeftBarButtonWithImage(barButtonImage!)
        }
        
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = .mainOrange
        refreshControl?.addTarget(self, action: #selector(handleRefresh), for: UIControlEvents.valueChanged)
        refreshControl?.beginRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        loadMessages()
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }
    
    func loadMessages() {
        GroupMessage.all().onSuccess(in: .main) { chats in
            self.chats = chats.sorted(descending: { $0.lastActivity ?? Date.distantPast })
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
        .onError(in: .main) { error in
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
        open(chat: chats[indexPath.row])
    }
    
    func handleRefresh(_ refreshControll: UIRefreshControl) {
        loadMessages()
    }
    
    @IBAction func compose(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let controller = storyboard.instantiateViewController(withIdentifier: "ChatViewController")
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func open(chat id: Int) {
        GroupMessage.groupMessage(with: id).onSuccess(call: self.open <** false)
    }
    
    func open(chat: GroupMessage, animated: Bool = true) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let controller = storyboard.instantiateViewController(withIdentifier: "ChatViewController")
        
        if let controller = controller as? ChatViewController {
            controller.chat = chat
        }
        
        self.navigationController?.pushViewController(controller, animated: animated)
    }
    
}
