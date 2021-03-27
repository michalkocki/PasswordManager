//
//  RegisterViewController.swift
//  PasswordManager
//
//  Created by Michał Kocki on 23/03/2021.
//

import UIKit
import CoreData
import CryptoKit

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var userObjectList: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FetchEntityData()
    }

    @IBAction func registerUser(_ sender: Any) {
        if(ValidateForm()) {
            if(CheckLoginAvailability(userName: loginTextField.text!)) {
                AddNewUser(login: loginTextField.text!, password: passwordTextField.text!)
                dismiss(animated: true, completion: nil)
            } else {
                let unavailableLoginAlert: UIAlertController = UIAlertController(title: "Błąd", message: "Podany login jest już zajęty.", preferredStyle: .alert)
                unavailableLoginAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                show(unavailableLoginAlert, sender: self)
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
    
    // Check if login is available
    func CheckLoginAvailability (userName: String) -> Bool {
        if userObjectList.count > 0 {
            for index in 0 ... userObjectList.count-1 {
                if(userName == userObjectList[index].value(forKeyPath: "userLogin") as? String) { return false }
            }
        }
        return true
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
    
    // Adding new user to the entity
    func AddNewUser(login: String, password: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let newUserEntity = NSEntityDescription.entity(forEntityName: "AppUsers", in: managedContext)!
        let newUserObject = NSManagedObject(entity: newUserEntity, insertInto: managedContext)
        newUserObject.setValue(login, forKey: "userLogin")
        let passwordData = Data(password.utf8)
        newUserObject.setValue(SHA512.hash(data: passwordData).description, forKey: "userPassword")
        
        let userKey = SymmetricKey(size: .bits256).withUnsafeBytes {
            Data(Array($0)).base64EncodedString()
        }
        newUserObject.setValue(userKey, forKey: "userSymmetricKey")

        do {
            try managedContext.save()
        }
        catch let error as NSError {
            print("Could not save new user. \(error), \(error.userInfo)")
        }
    }
    
//    func GenerateRandomSalt() -> String {
//        var randomSalt: String = ""
//        for _ in 0 ... 32 {
//            randomSalt += String(Int.random(in: 0..<10))
//        }
//        return randomSalt
//    }
    
}
