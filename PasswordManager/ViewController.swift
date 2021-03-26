//
//  ViewController.swift
//  PasswordManager
//
//  Created by Michał Kocki on 19/03/2021.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    var addedPasswords: [NSManagedObject] = []
    var selectionIndex: Int = 0

    // Function is needed to make the modal card buttons work - PreviewViewController 'check' button
    @IBAction func unwindSegue(segue: UIStoryboardSegue) {}
    
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
    
    // Pass the selection index value to the PreviewViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "PreviewPasswordSegue") {
            let previewPasswordSegue = segue.destination as! PreviewViewController
            previewPasswordSegue.passwordToPreview = addedPasswords[selectionIndex]
        }
    }
    
    // Fetch saved passwords to the array
    func fetchData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Password")
        do {
            addedPasswords = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch data. \(error), \(error.userInfo)")
        }
    }
}

// MARK: Extension: TableView DataSource, Delegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    // Number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addedPasswords.count
    }

    // Setting up cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let password = addedPasswords[indexPath.row]
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        cell.textLabel?.text = password.value(forKeyPath: "webpage") as? String
        cell.detailTextLabel?.text = password.value(forKeyPath: "login") as? String
        return cell
    }
    
    // Swipe to delete functionality
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            managedContext.delete(addedPasswords[indexPath.row])
            do {
                try managedContext.save()
            }
            
            catch let error as NSError {
                print("Could not delete. \(error), \(error.userInfo)")
            }
            
            addedPasswords.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // Called when single row is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectionIndex = indexPath.row
        self.performSegue(withIdentifier: "PreviewPasswordSegue", sender: self)
    }
}
