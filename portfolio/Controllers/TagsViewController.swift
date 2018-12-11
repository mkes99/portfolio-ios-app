//
//  TagsViewController.swift
//  portfolio
//
//  Created by Formative Mini on 9/22/18.
//  Copyright © 2018 Formative Web Solutions. All rights reserved.
//

import UIKit
import Firebase

class TagsViewController: UIViewController {
    var user: UserModel!
    
    @IBOutlet weak var textFieldTag: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textFieldTag.setupField()
        LoggedInViewController().fetchUser()
        
        let center: NotificationCenter = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name:
            UIResponder.keyboardDidShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    @IBAction func saveDidTouch(_ sender: UIButton) {
        saveTagsHandler()
    }

    @IBAction func doneTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func keyboardDidShow(notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        let keyboardY = self.view.frame.size.height - keyboardSize.height
        
        UIView.animate(withDuration: 0.0, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.view.frame = CGRect(x: 0, y : self.view.frame.origin.y - (self.saveButton.frame.origin.y - (keyboardY - 60)), width: self.view.bounds.width, height: self.view.bounds.height)
        }, completion: nil)
    }
    @objc func keyboardDidHide(notification: Notification) {
        UIView.animate(withDuration: 0.0, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.view.frame = CGRect(x: 0, y : 0, width: self.view.bounds.width, height: self.view.bounds.height)
        }, completion: nil)
    }
}

extension TagsViewController {
    func saveTagsHandler() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        let tagsRef = Database.database().reference().child("tags").child(user.uid).childByAutoId()
        tagsRef.setValue(["tag": textFieldTag.text])
        textFieldTag.text = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textFieldTag {
            textField.resignFirstResponder()
            saveTagsHandler()
        } 
        return true
    }
}
