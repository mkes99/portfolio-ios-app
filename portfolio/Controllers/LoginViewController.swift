//
//  LoginViewController.swift
//  portfolio
//
//  Created by Formative Mini on 9/5/18.
//  Copyright © 2018 Formative Web Solutions. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController{

    @IBOutlet weak var textFieldLoginEmail: UITextField!
    @IBOutlet weak var textFieldLoginPassword: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var accountQuestion: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = .white
        
        Auth.auth().addStateDidChangeListener() { auth, user in
            if user != nil {
                if let navController = UIStoryboard(name: "LoggedIn", bundle: nil).instantiateInitialViewController() as? UINavigationController {
                    self.present(navController, animated: true, completion: nil)
                }
                self.textFieldLoginEmail.text = nil
                self.textFieldLoginPassword.text = nil
            }
        }
        
        textFieldLoginEmail.setupField()
        textFieldLoginEmail.delegate = self
        textFieldLoginPassword.setupField()
        textFieldLoginPassword.delegate = self
        
        self.hideKeyboardWhenTappedAround() 
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    @IBAction func loginDidTouch(_ sender: UIButton) {
        handleLogin()
    }
    
    @IBAction func accountNoTapped(_ sender: UIButton) {
        if let navController = UIStoryboard(name: "SignIn", bundle: nil).instantiateInitialViewController() as? UINavigationController {
            self.present(navController, animated: true, completion: nil)
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func handleLogin() {
        guard let email = textFieldLoginEmail.text, let password = textFieldLoginPassword.text else {
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if let error = error {
                let alert = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
                return
            }
        })
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textFieldLoginEmail {
            textField.resignFirstResponder()
            textFieldLoginPassword.becomeFirstResponder()
        } else if textField == textFieldLoginPassword {
            textField.resignFirstResponder()
            handleLogin()
        }
        return true
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let offset = UIScreen.main.bounds.height / 3
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height - offset
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}
