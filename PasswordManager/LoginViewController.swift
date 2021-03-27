//
//  LoginViewController.swift
//  PasswordManager
//
//  Created by Michał Kocki on 20/03/2021.
//

import UIKit
import CoreData
import CryptoKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var userObjectList: [NSManagedObject] = []
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FetchEntityData()
    }
    
    
    @IBAction func unwindSegue(segue: UIStoryboardSegue) {}

    // Function is called when the 'login' button is tapped
    @IBAction func login(_ sender: Any) {
        FetchEntityData()
        if(ValidateForm()) {
            if(CheckLogin(userName: loginTextField.text!)) {
                userDefaults.set(loginTextField.text!, forKey: "currentUser")
                performSegue(withIdentifier: "SegueToMainViewController", sender: self)
            } else {
                let incorrectPasswordAlert: UIAlertController = UIAlertController(title: "Błąd", message: "Nieprawidłowy login lub hasło", preferredStyle: .alert)
                incorrectPasswordAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                show(incorrectPasswordAlert, sender: self)
            }
        }
    }
    
    // Fetch data from CoreData entity with registered users and append it to the array
    func FetchEntityData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "AppUsers")
        do {
            userObjectList = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch data. \(error), \(error.userInfo)")
        }
    }
    
    // Check if login is present in registered users array
    func CheckLogin (userName: String) -> Bool {
        if userObjectList.count > 0 {
            for index in 0 ... userObjectList.count-1 {
                if(userName == userObjectList[index].value(forKeyPath: "userLogin") as? String) {
                    
                    // Check if hashed password from login form is the same as user's hashed password - using SHA512
                    let checkedPasswordData = Data(passwordTextField.text!.utf8)
                    if(SHA512.hash(data: checkedPasswordData).description) == userObjectList[index].value(forKeyPath: "userPassword") as? String {
                        userDefaults.set(userObjectList[index].value(forKeyPath: "userSymmetricKey"), forKey: "currentUserKey")
                        return true
                    }
                    
                }
            }
        }
        return false
    }
    
    // Check if form is not empty
    func ValidateForm() -> Bool {
        let validationAlert: UIAlertController = UIAlertController(title: "Błąd", message: "Wypełnij login i hasło!", preferredStyle: .alert)
        validationAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        guard let _ = loginTextField.text, !loginTextField.text!.isEmpty, loginTextField.text!.count > 0  else {
            show(validationAlert, sender: self)
                return false
            }
        
        guard let _ = passwordTextField.text, !passwordTextField.text!.isEmpty, passwordTextField.text!.count > 0  else {
            show(validationAlert, sender: self)
                return false
            }
        
        return true
    }

}
