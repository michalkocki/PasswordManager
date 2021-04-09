//
//  PasswordManagerTests.swift
//  PasswordManagerTests
//
//  Created by Michał Kocki on 19/03/2021.
//

import XCTest
import CryptoKit
@testable import PasswordManager

class PasswordManagerTests: XCTestCase {

    var sutNewPasswordVC: NewPasswordViewController!
    var sutRegisterVC: RegisterViewController!
    
    
    override func setUpWithError() throws {
        super.setUp()
        sutNewPasswordVC = NewPasswordViewController()
        sutRegisterVC = RegisterViewController()
    }

    override func tearDownWithError() throws {
        sutNewPasswordVC = nil
        sutRegisterVC = nil
        super.tearDown()
    }
    
    func testPasswordIsAdded() {
        let testPassword = "password!"
        let testKey = SymmetricKey(size: .bits256).withUnsafeBytes {
            Data(Array($0)).base64EncodedString()
        }
        
        XCTAssertNotNil(sutNewPasswordVC.sealUserPassword(passwordText: testPassword, currentUserKey: testKey))
    }
    
    func testLogAction() {
        let action = "Test action"
        let previous = Data.init()
        let updated = Data.init()
        let user = "Test user"
        
        XCTAssertNoThrow(sutNewPasswordVC.logAction(Action: action, CurrentUser: user, PreviousValue: previous, UpdatedValue: updated))
    }
    
    func testAddUser() {
        let testLogin = "test"
        let testPassword = "password"
        
        XCTAssertNoThrow(sutRegisterVC.AddNewUser(login: testLogin, password: testPassword))
    }
    
    func testFetchEntityData() {
        XCTAssertNoThrow(sutRegisterVC.FetchEntityData())
    }
    
    

}
