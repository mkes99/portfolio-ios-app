//
//  EditImageViewController.swift
//  portfolio
//
//  Created by Formative Mini on 9/20/18.
//  Copyright © 2018 Formative Web Solutions. All rights reserved.
//

import UIKit
import Firebase

protocol ImageInfoViewDelegate: AnyObject {
    func sendData(title: String, selectedTags: [String])
}

class imageInfoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    weak var delegate: ImageInfoViewDelegate?

    @IBOutlet weak var imageTitle: UITextField!
    @IBOutlet weak var addTag: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var saveTag: UIButton!
    @IBOutlet weak var slideIndicator: UIButton!
    
    struct tagStruct: Equatable {
        let title: String
        let value : String
        var isSelected = false
    }
 
    var tag: TagModel!
    var tags = [tagStruct]()
    var selectedImage: UIImage!
    
    var user: User?
    
    var lastKey: String = ""
    var allTags: Bool = false
    
    var imageId: String?
    var postTitle: String?
    var postTags: [tagStruct]?
    
    var seenTags = Set<String>()
    var uniqueTags: [tagStruct] = []
    var totalTagCount: Int = 0
    
    let await = DispatchGroup()
    
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
        
        imageTitle.setupField()
        imageTitle.delegate = self
        addTag.setupField()
        addTag.delegate = self
        
        saveButton.setTitle("Save", for: .normal)
        
        if let currentUser = UserManager.shared.CURRENT_USER {
            self.user = currentUser
            
            TagsManager.shared.fetchTagCount(userId: currentUser.uid, completion: { count in
                self.totalTagCount = count
            })
            
            if let postId = imageId {
                fetchPost(uid: currentUser.uid, postId: postId)
            } else {
                fetchTags(uid: currentUser.uid, postTags: [])
            }
        }
    }
    
    @IBAction func saveTagTapped(_ sender: UIButton) {
        if let tagField = addTag.text, !tagField.isEmpty {
            saveTagsHandler()
            tableView?.reloadData()
        } else {
            let alert = UIAlertController(title: "Validation Error", message: "Add to tag filed must have a value before you can save.", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        dismissView(save: false)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        dismissView(save: true)
    }
    
    func dismissView(save: Bool) {
        dismiss(animated: true, completion: {
            self.delegate?.sendData(title: self.imageTitle.text ?? "", selectedTags: save ? self.uniqueTags.filter{$0.isSelected}.map{$0.value} : [])
            self.tableView?.reloadData()
        })
    }
    
    func fetchTags(uid: String, postTags: [String]) {
        if allTags == false {
            let limit = UInt(5)
            switch !postTags.isEmpty {
            case true:
                var postResults: UInt = 0
                TagsManager.shared.queryPostTags(uid: uid, tagsIds: postTags, completion: {results in
                    postResults = UInt(results.count)
                    results.forEach({ (result) in
                        let tag = tagStruct(title: result.title ?? "", value: result.value ?? "", isSelected : true)
                        self.tags.append(tag)
                        if !self.seenTags.contains(tag.title) {
                            self.uniqueTags.append(tag)
                            self.seenTags.insert(tag.title)
                        }
                    })
                    if postResults < limit {
                        TagsManager.shared.queryTagsPage(withId: uid, start: self.lastKey, limit: limit, completion: { (results) in
                            
                            if let lastValue = results.last?.title {
                                self.lastKey = lastValue
                            }
                            results.forEach({ (result) in
                                let tag = tagStruct(title: result.title ?? "", value: result.value ?? "", isSelected : false)
                                self.tags.append(tag)
                                if !self.seenTags.contains(tag.title) {
                                    self.uniqueTags.append(tag)
                                    self.seenTags.insert(tag.title)
                                }
                                
                            })
                            if self.seenTags.count == self.totalTagCount{
                                self.allTags = true
                            }
                            self.tableView?.reloadData()
                        })
                    } else {
                        if self.seenTags.count == self.totalTagCount{
                            self.allTags = true
                        }
                        self.tableView?.reloadData()
                    }
                })
            case false:
                TagsManager.shared.queryTagsPage(withId: uid, start: lastKey, limit: limit, completion: { (results) in
                    
                    if let lastValue = results.last?.title {
                        self.lastKey = lastValue
                    }
                    results.forEach({ (result) in
                        let tag = tagStruct(title: result.title ?? "", value: result.value ?? "", isSelected : false)
                        self.tags.append(tag)
                        if !self.seenTags.contains(tag.title) {
                            self.uniqueTags.append(tag)
                            self.seenTags.insert(tag.title)
                        }
                        
                    })
                    if self.seenTags.count == self.totalTagCount{
                        self.allTags = true
                    }
                    self.tableView?.reloadData()
                })
            }
        }
    }
    
    func fetchPost(uid: String, postId: String) {
        PostsManager.shared.queryPostWithId(withPostId: postId, userId: uid, completion: { post in
            self.imageTitle.text = post.title
            self.saveButton.setTitle("Update", for: .normal)

            self.fetchTags(uid: uid, postTags: post.tags ?? [])

        })
    }
}

extension imageInfoViewController: UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate{
    func saveTagsHandler() {
        guard let user = user else { return }
        guard let tagText = addTag.text else {return}
        TagsManager.shared.saveTags(withUserId: user.uid, tagText: tagText, timeStamp: Int(Date().timeIntervalSince1970), completion: { tag in
            self.tags.insert(tagStruct(title: tag.title!, value: tag.value!, isSelected : false), at: 0)
            self.tableView?.reloadData()
        })
        addTag.text = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == imageTitle {
            textField.resignFirstResponder()
        } else if textField == addTag {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return uniqueTags.count
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
        cell.textLabel?.text = uniqueTags[indexPath.item].title
        
        if imageId != nil && uniqueTags[indexPath.item].isSelected{
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let cell = tableView.cellForRow(at: indexPath)
        if (cell?.accessoryType == UITableViewCell.AccessoryType.checkmark){
            uniqueTags[indexPath.item].isSelected = false;
            cell!.accessoryType = UITableViewCell.AccessoryType.none
        }else{
            uniqueTags[indexPath.item].isSelected = true;
            cell!.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
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
                self.uniqueTags.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                self.tableView.reloadData()
             
            }))
            
            alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard let user = user else { return }
        let currentOffset = scrollView.contentOffset.y
        let maxOffset = scrollView.contentSize.height - scrollView.frame.height
        
        if maxOffset - currentOffset <= 40 {
           fetchTags(uid: user.uid, postTags: [])
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
