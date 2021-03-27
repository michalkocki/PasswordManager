//
//  PreviewViewController.swift
//  PasswordManager
//
//  Created by Michał Kocki on 20/03/2021.
//

import UIKit
import CoreData
import CryptoKit

class PreviewViewController: UIViewController {
    
    @IBOutlet weak var webpageLabel: UILabel!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    var passwordToPreview: NSManagedObject = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webpageLabel.text = passwordToPreview.value(forKeyPath: "webpage") as? String
        loginLabel.text = passwordToPreview.value(forKeyPath: "login") as? String
        passwordLabel.text = openSealedPassword()
        

    }
    
    func openSealedPassword() -> String {
        let currentUserKey = UserDefaults.standard.object(forKey: "currentUserKey") as! String
        guard let keyData = Data(base64Encoded: currentUserKey) else { return "Error occured" }
        let sealedBox = passwordToPreview.value(forKeyPath: "aesPassword") as! Data
        let sealedData = try! AES.GCM.SealedBox(combined: sealedBox)

        let decryptedData = try! AES.GCM.open(sealedData, using: SymmetricKey(data: keyData))
        let unsealedPassword = String(decoding: decryptedData, as: UTF8.self)
        return unsealedPassword
    }
    
}
