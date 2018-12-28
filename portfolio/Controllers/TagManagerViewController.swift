//
//  EditImageViewController.swift
//  portfolio
//
//  Created by Formative Mini on 9/20/18.
//  Copyright © 2018 Formative Web Solutions. All rights reserved.
//

import UIKit
import Firebase

protocol TagManagerViewDelegate: AnyObject {
    func dismissTagManager()
}

class tagManagerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    weak var delegate: TagManagerViewDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var newTag: UITextField!
    
    @IBOutlet weak var saveTag: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var slideIndicator: UIButton!
    
    struct tagStruct: Equatable {
        let title: String
        let value : String
        var isSelected = false
    }
    
    var tag: TagModel!
    var tags = [tagStruct]()
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = .white
        
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurVisualEffectView = UIVisualEffectView(effect: blurEffect)
        blurVisualEffectView.frame = view.bounds
        
        self.view.backgroundColor = .clear
        view.insertSubview(blurVisualEffectView, at: 0)
        
        slideIndicator.layer.cornerRadius = slideIndicator.frame.height / 2
        
        tableView.separatorColor = .white
        tableView.layer.masksToBounds = true
        tableView.layer.borderColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1 ).cgColor
        tableView.layer.borderWidth = 2.0
        tableView.dataSource = self
        tableView.delegate = self
        
        newTag.setupField()
        newTag.delegate = self
        
        if let currentUser = UserManager.shared.CURRENT_USER {
            self.user = currentUser
        }
        
        self.hideKeyboardWhenTappedAround() 
    }
    
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        if let tagField = newTag.text, !tagField.isEmpty {
            saveTagsHandler()
            tableView?.reloadData()
        } else {
            let alert = UIAlertController(title: "Validation Error", message: "Add to tag filed must have a value before you can save.", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        delegate?.dismissTagManager()
    }
    
}

extension tagManagerViewController: UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate{
    func saveTagsHandler() {
        guard let user = user else { return }
        guard let tagText = newTag.text else {return}
        TagsManager.shared.saveTags(withUserId: user.uid, tagText: tagText, timeStamp: Int(Date().timeIntervalSince1970), completion: { tag in
            self.tags.insert(tagStruct(title: tag.title!, value: tag.value!, isSelected : false), at: 0)
            print(tag)
            self.tableView?.reloadData()
        })
        newTag.text = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == newTag {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "tagCell", for: indexPath)
        cell = UITableViewCell(style: .value1, reuseIdentifier: "tagCell")
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        cell.backgroundColor = .clear
        let backgroundView = UIView()
        backgroundView.backgroundColor = .black
        cell.selectedBackgroundView = backgroundView
        cell.textLabel?.textColor = .white
        cell.textLabel?.text = tags[indexPath.item].title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let alert = UIAlertController(title: "DELETE POST", message: "By selecting continue you will remove this tag permantly from the application.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { _ in
                guard let user = self.user else { return }
                TagsManager.shared.deleteTag(withTagId: self.tags[indexPath.row].value, uid: user.uid)
                self.tags.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                self.tableView.reloadData()
                
            }))
            
            alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
