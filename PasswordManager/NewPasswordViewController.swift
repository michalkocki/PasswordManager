//
//  NewPasswordViewController.swift
//  PasswordManager
//
//  Created by Michał Kocki on 19/03/2021.
//

import UIKit
import CoreData

class NewPasswordViewController : UIViewController {
    
//    Storyboard elements
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var webpageTextField: UITextField!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
        
    @IBAction func savePassword(_ sender: Any) {
        performSegue(withIdentifier: "secondUnwindToMainViewController", sender: self)
    }
    
    @IBAction func cancelPassword(_ sender: Any) {}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let passwordEntity = NSEntityDescription.entity(forEntityName: "Password", in: managedContext)!
        let newPassword = NSManagedObject(entity: passwordEntity, insertInto: managedContext)
        
        newPassword.setValue(webpageTextField.text!, forKey: "webpage")
        newPassword.setValue(loginTextField.text!, forKey: "login")
        //        Hash password here!
        newPassword.setValue(passwordTextField.text!, forKey: "pass")

        if let vc = segue.destination as? ViewController {
            do {
                try managedContext.save()
                vc.passwords.append(newPassword)
                vc.tableView.reloadData()
            }
            catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
}
