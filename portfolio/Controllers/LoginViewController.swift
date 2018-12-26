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
        
        let center: NotificationCenter = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name:
            UIResponder.keyboardDidShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
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
            print("Form is not valid")
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
    
    @objc func keyboardDidShow(notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        let keyboardY = self.view.frame.size.height - keyboardSize.height
        
        UIView.animate(withDuration: 0.0, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.view.frame = CGRect(x: 0, y : self.view.frame.origin.y - (self.loginButton.frame.origin.y - (keyboardY - 60)), width: self.view.bounds.width, height: self.view.bounds.height)
        }, completion: nil)
    }
    @objc func keyboardDidHide(notification: Notification) {
        UIView.animate(withDuration: 0.0, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.view.frame = CGRect(x: 0, y : 0, width: self.view.bounds.width, height: self.view.bounds.height)
        }, completion: nil)
    }
}
