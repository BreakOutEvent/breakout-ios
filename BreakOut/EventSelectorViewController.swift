//
//  EventSelector.swift
//  BreakOut
//
//  Created by Mathias Quintero on 4/8/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import UIKit
import Sweeft

protocol EventSelectorDelegate: class {
    func eventSelector(_ eventSelector: EventSelectorViewController, didChange selected: [Int])
}

class EventSelectorViewController: UIViewController {
    
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: EventSelectorDelegate?
    
    var events = [Event]()
    var selected = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundView?.backgroundColor = .clear
        tableView.backgroundColor = .clear
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.setEditing(true, animated: false)
        let effect = UIBlurEffect(style: .extraLight)
        let effectView = UIVisualEffectView(effect: effect)
        effectView.clipsToBounds = true
        effectView.frame = blurView.bounds
        blurView.addSubview(effectView)
        Event.all().onSuccess { events in
            self.events = events
            self.tableView.reloadData()
        }
        Event.currentId().onSuccess { id in
            self.selected = [id]
            self.updateDelegate()
            self.tableView.reloadData()
        }
    }
    
    func updateDelegate() {
        delegate?.eventSelector(self, didChange: selected)
    }
    
    @IBAction func didSelectAll(_ sender: Any) {
        selected = events => { $0.id }
        tableView.reloadData()
        updateDelegate()
    }
    
    @IBAction func didDeselectAll(_ sender: Any) {
        selected = []
        tableView.reloadData()
        updateDelegate()
    }
    
}

extension EventSelectorViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected.append(events[indexPath.row].id)
        updateDelegate()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selected = selected |> { $0 != events[indexPath.row].id }
        updateDelegate()
    }
    
}

extension EventSelectorViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "event", for: indexPath)
        cell.textLabel?.text = events[indexPath.row].title
        cell.selectionStyle = .default
        cell.multipleSelectionBackgroundView = UIView()
        cell.multipleSelectionBackgroundView?.backgroundColor = .clear
        if selected.contains(events[indexPath.row].id) {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        return cell
    }
    
}
