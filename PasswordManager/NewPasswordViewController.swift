//
//  NewPasswordViewController.swift
//  PasswordManager
//
//  Created by Michał Kocki on 19/03/2021.
//

import UIKit
import CoreData
import CryptoKit

class NewPasswordViewController : UIViewController {
    
//    Storyboard elements
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var webpageTextField: UITextField!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
        
    @IBAction func savePassword(_ sender: Any) {
        performSegue(withIdentifier: "secondUnwindToMainViewController", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let passwordEntity = NSEntityDescription.entity(forEntityName: "Password", in: managedContext)!
        let newPassword = NSManagedObject(entity: passwordEntity, insertInto: managedContext)
        let currentUserKey = UserDefaults.standard.object(forKey: "currentUserKey") as! String
        let sealedPassword: Data = sealUserPassword(passwordText: passwordTextField.text!, currentUserKey: currentUserKey)
        
        newPassword.setValue(webpageTextField.text!, forKey: "webpage")
        newPassword.setValue(loginTextField.text!, forKey: "login")
        newPassword.setValue(sealedPassword, forKey: "aesPassword")
        newPassword.setValue(UserDefaults.standard.object(forKey: "currentUser") as! String, forKey: "user")
        logAction(Action: "Password added", CurrentUser: UserDefaults.standard.object(forKey: "currentUser") as! String, PreviousValue: sealedPassword, UpdatedValue: sealedPassword)
        
        if let vc = segue.destination as? ViewController {
            do {
                try managedContext.save()
                vc.addedPasswords.append(newPassword)
                vc.tableView.reloadData()
            }
            catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    func sealUserPassword(passwordText: String, currentUserKey: String) -> Data {
        guard let keyData = Data(base64Encoded: currentUserKey) else { return Data.init() }
        let sealedPass = try! AES.GCM.seal(Data(passwordText.utf8), using: SymmetricKey(data: keyData)).combined
        return sealedPass!
    }
    
    func logAction(Action action: String, CurrentUser user: String, PreviousValue previousValue: Data, UpdatedValue updatedValue: Data) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let passwordEntity = NSEntityDescription.entity(forEntityName: "Logs", in: managedContext)!
        let newLog = NSManagedObject(entity: passwordEntity, insertInto: managedContext)
        let logID = UUID.init()
        let timestamp = Date.init()
        
        newLog.setValue(logID, forKey: "id")
        newLog.setValue(action, forKey: "action")
        newLog.setValue(timestamp, forKey: "timestamp")
        newLog.setValue(user, forKey: "user")
        newLog.setValue(previousValue, forKey: "previous_value")
        newLog.setValue(updatedValue, forKey: "updated_value")
        
        do {
            try managedContext.save()
            print("\(timestamp.description): \(action) (ID: \(logID))")
        }
        catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}
