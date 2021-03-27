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
        guard let keyData = Data(base64Encoded: currentUserKey) else { return }
        let sealedPassword = try! AES.GCM.seal(Data(passwordTextField.text!.utf8), using: SymmetricKey(data: keyData)).combined

        newPassword.setValue(webpageTextField.text!, forKey: "webpage")
        newPassword.setValue(loginTextField.text!, forKey: "login")
        newPassword.setValue(sealedPassword, forKey: "aesPassword")
        newPassword.setValue(UserDefaults.standard.object(forKey: "currentUser") as! String, forKey: "user")

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
}
