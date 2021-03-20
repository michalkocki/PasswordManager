//
//  ViewController.swift
//  PasswordManager
//
//  Created by Michał Kocki on 19/03/2021.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
//   Storyboard elements
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
//   Buttons in card views don't work without unwindSegue
    @IBAction func unwindSegue(segue: UIStoryboardSegue) {}
    
//   Globals
    var passwords: [NSManagedObject] = []
    var selectionIndex: Int = 0


    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Your passwords"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "PreviewPasswordSegue") {
        let previewPasswordSegue = segue.destination as! PreviewViewController
        previewPasswordSegue.passwordToPreview = passwords[selectionIndex]
        }
    }
    
    func fetchData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Password")
        
        do {
            passwords = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch data. \(error), \(error.userInfo)")
        }
    }
    
    
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return passwords.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let password = passwords[indexPath.row]
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        cell.textLabel?.text = password.value(forKeyPath: "webpage") as? String
        cell.detailTextLabel?.text = password.value(forKeyPath: "login") as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            managedContext.delete(passwords[indexPath.row])
            
            do { try managedContext.save() }
            catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
            passwords.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectionIndex = indexPath.row
        self.performSegue(withIdentifier: "PreviewPasswordSegue", sender: self)
    }
    

}
