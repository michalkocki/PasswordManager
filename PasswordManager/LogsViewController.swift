//
//  LogsViewController.swift
//  PasswordManager
//
//  Created by Michał Kocki on 02/04/2021.
//

import UIKit
import CoreData

class LogsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var savedLogs: [NSManagedObject] = []
    let userDefaults = UserDefaults.standard
    var selectionIndex: Int = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    // Fetching and reloading table everytime when view is appearing
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
        self.tableView.reloadData()
    }
    
    // Fetch logs to the array
    func fetchData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Logs")
        let currentUserName = UserDefaults.standard.object(forKey: "currentUser") as! String
        let predicate = NSPredicate(format: "user == %@", currentUserName)
        fetchRequest.predicate = predicate
        do {
            savedLogs = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch data. \(error), \(error.userInfo)")
        }
    }
    
    
}

// MARK: Extension: TableView DataSource, Delegate
extension LogsViewController: UITableViewDataSource, UITableViewDelegate {
    
    // Number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedLogs.count
    }

    // Setting up cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let log = savedLogs[indexPath.row]
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let detailTimestampText: Date = log.value(forKey: "timestamp") as! Date
        cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        cell.textLabel?.text = log.value(forKeyPath: "action") as? String
        cell.detailTextLabel?.text = detailTimestampText.description
        return cell
    }
    
    // Called when single row is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectionIndex = indexPath.row
    }
}
