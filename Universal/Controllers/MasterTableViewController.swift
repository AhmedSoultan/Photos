//
//  ViewController.swift
//  Universal
//
//  Created by Ahmed Sultan on 7/20/19.
//  Copyright © 2019 Ahmed Sultan. All rights reserved.
//

import UIKit
import SQLite

class MasterTableViewController: UITableViewController {
    //MARK: - Properties
    var items = SQLiteManager.shared().listOfItems()
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let addNewItemBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(MasterTableViewController.addNewItemAction))
        navigationItem.rightBarButtonItem = addNewItemBarButton
        navigationItem.title = "Items"
        //title = "Items"
    
    }
    override func viewDidLayoutSubviews() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            if navigationItem.rightBarButtonItems != nil &&
                navigationItem.rightBarButtonItems!.count <= 1 {
                let optionsBarButton = UIBarButtonItem(title: "Options", style: UIBarButtonItem.Style.plain, target: self, action: #selector(MasterTableViewController.optionBarButtonAction))
                navigationItem.rightBarButtonItems?.append(optionsBarButton)
            }
        }
    }
  
    
    //MARK: - Costum actions
    @objc func addNewItemAction () {
        let addNewItemVC = storyboard?.instantiateViewController(withIdentifier: "newItemViewController") as! NewItemViewController
        addNewItemVC.delegate = self
        let navigationController = UINavigationController(rootViewController: addNewItemVC)
        present(navigationController, animated: true)
    }
    @objc func optionBarButtonAction() {
        guard let splitVC = self.splitViewController else {
            print("no split view controller")
            return
        }
        let optionAlert = UIAlertController(title: "Options", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        optionAlert.addAction(UIAlertAction(title: "Alwayse hide left pane", style: UIAlertAction.Style.default, handler: { (_) in
            splitVC.preferredDisplayMode = .primaryHidden
            UserDefaults.standard.set(false, forKey: keys.udKeySplitPreferredDisplayMode)
        }))
        optionAlert.addAction(UIAlertAction(title: "Alwayse show lift pane", style: UIAlertAction.Style.default, handler: { (_) in
            splitVC.preferredDisplayMode = .allVisible
            UserDefaults.standard.set(true, forKey: keys.udKeySplitPreferredDisplayMode)
        }))
        if let popoverPresentationController = optionAlert.popoverPresentationController,
            let navigationBar = self.navigationController?.navigationBar {
            popoverPresentationController.sourceView = navigationBar
            popoverPresentationController.sourceRect = navigationBar.bounds
        }
        DispatchQueue.main.async {
            self.present(optionAlert, animated: true, completion: nil)
        }
    }
}
extension MasterTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let name = items[indexPath.row].name
        cell.textLabel?.text = name
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = storyboard?.instantiateViewController(withIdentifier: "detailViewController") as! DetailsViewController
        detailVC.item = items[indexPath.row]
        splitViewController?.showDetailViewController(detailVC, sender: self)
    }
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: UIContextualAction.Style.normal, title: "Delete") { (ction, view, done) in
            let deletedItem = self.items[indexPath.row]
            SQLiteManager.shared().delete(item: deletedItem, completion: { (done) in
                if done {
                    self.items.remove(at: indexPath.row)
                    self.tableView.reloadData()
                }
            })
        }
        action.backgroundColor = .red
        //action.image = UIImage(named: "delete")
        return UISwipeActionsConfiguration(actions: [action])
    }
}
extension MasterTableViewController: AddNewItem {
    func didCreate(newItem: Item) {
        items.append(newItem)
        let indexPath = IndexPath(row: items.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: UITableView.RowAnimation.fade)
        tableView.reloadData()
    }
    
    
}

