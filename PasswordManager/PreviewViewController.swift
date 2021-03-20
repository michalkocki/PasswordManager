//
//  PreviewViewController.swift
//  PasswordManager
//
//  Created by Michał Kocki on 20/03/2021.
//

import UIKit
import CoreData

class PreviewViewController: UIViewController {
    
    @IBOutlet weak var webpageLabel: UILabel!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    var passwordToPreview: NSManagedObject = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webpageLabel.text = passwordToPreview.value(forKeyPath: "webpage") as? String
        loginLabel.text = passwordToPreview.value(forKeyPath: "login") as? String
        passwordLabel.text = passwordToPreview.value(forKeyPath: "pass") as? String

    }
    
}
