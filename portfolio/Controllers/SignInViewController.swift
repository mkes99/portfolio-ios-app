//
//  SignInViewController.swift
//  portfolio
//
//  Created by Formative Mini on 9/13/18.
//  Copyright © 2018 Formative Web Solutions. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var textFieldLoginName: UITextField!
    @IBOutlet weak var textFieldLoginEmail: UITextField!
    @IBOutlet weak var textFieldLoginPassword: UITextField!
    @IBOutlet weak var accountQuestion: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    var selectedImage: UIImage?
    
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
                self.textFieldLoginName.text = nil
                self.textFieldLoginEmail.text = nil
                self.textFieldLoginPassword.text = nil
            }
        }
        
        textFieldLoginName.setupField()
        textFieldLoginName.delegate = self
        textFieldLoginEmail.setupField()
        textFieldLoginEmail.delegate = self
        textFieldLoginPassword.setupField()
        textFieldLoginPassword.delegate = self
        
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
        profileImage.layer.masksToBounds = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleSelectProfileImageView))
        profileImage.addGestureRecognizer(tapGesture)
        profileImage.isUserInteractionEnabled = true
        
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
        handleRegister()
    }
    
    @IBAction func accountYesTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension SignInViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func handleRegister() {
        guard let email = textFieldLoginEmail.text, let password = textFieldLoginPassword.text, let name = textFieldLoginName.text else {
            print("Form is not valid")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { user, error in
            if let error = error {
                let alert = UIAlertController(title: "Create New User Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            guard let uid = user?.user.uid else { return }
            
            let userRef = Database.database().reference().child("users").child(uid)
        
            if self.selectedImage != nil {
                ImageUploadManager.shared.uploadImage(imageToUpload: self.selectedImage, storageName: "profile_image", uid: uid, progressBlock: { (percentage) in },completion: { (fileURL, error) in
                    if (error != nil) {
                        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
                        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
                        
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    if let imageUrl = fileURL{
                        userRef.setValue(["name": name, "email": email, "password": password, "profileImage" : imageUrl.absoluteString])
                    }
                })
            } else {
                userRef.setValue(["name": name, "email": email, "password": password])
            }
        })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        print("did Finish Picking Media")
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImage = image
            profileImage.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case textFieldLoginName:
            textField.resignFirstResponder()
            textFieldLoginEmail.becomeFirstResponder()
        case textFieldLoginEmail:
            textField.resignFirstResponder()
            textFieldLoginPassword.becomeFirstResponder()
        case textFieldLoginPassword:
            textField.resignFirstResponder()
            handleRegister()
        default:
            break
        }
        return true
    }
    
    @objc func handleSelectProfileImageView() {
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self
        myPickerController.sourceType = .photoLibrary
        present(myPickerController, animated: true, completion: nil)
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
