//
//  EditImageViewController.swift
//  portfolio
//
//  Created by Formative Mini on 9/20/18.
//  Copyright © 2018 Formative Web Solutions. All rights reserved.
//

import UIKit
import Firebase

class imageInfoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    struct tagStruct {
        let title: String
        let value : String
        var isSelected = false
        
    }
    
    var tag: TagModel!
    var tags = [tagStruct]()
    var selectedImage: UIImage!
    
    var user: User?
    
    var delegate: ClassPreviewDelegate?
    
    @IBOutlet weak var imageTitle: UITextField!
    @IBOutlet weak var addTag: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
    @IBOutlet weak var saveTag: UIButton!

    @IBOutlet weak var tagsLabel: UILabel!
    
    var imageId: String?
    var postTitle: String?
    var postTags: [tagStruct]?
    
  

    override func viewDidLoad() {
        super.viewDidLoad()
       
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = .white
        
        let blurEffect = UIBlurEffect(style: .light)
        let blurVisualEffectView = UIVisualEffectView(effect: blurEffect)
        blurVisualEffectView.frame = view.bounds
        self.view.insertSubview(blurVisualEffectView, at: 0)
        
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
        
        if let currentUser = UserManager.shared.CURRENT_USER {
            self.user = currentUser
            PostsManager.shared.queryTags(withId: currentUser.uid, completion: { (tag) in
                self.tag = tag
                self.tags.insert(tagStruct(title: self.tag.title ?? "", value: self.tag.value ?? "", isSelected : false), at: 0)
                self.fetchPostTags(uid: currentUser.uid)
                self.tableView?.reloadData()
            })
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
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) { 
         dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        let selectedTags = tags.filter{$0.isSelected}.map{$0.value}
        
        dismiss(animated: true, completion: {
            self.delegate?.sendData(title: self.imageTitle.text ?? "", selectedTags: selectedTags)
            self.tableView?.reloadData()
        })
    }
    
    func fetchPostTags(uid: String) {
        if let postId = imageId {
            PostsManager.shared.queryPostWithId(withPostId: postId, userId: uid, completion: { post in
                self.imageTitle.text = post.title

                
//                if let tags = self.postTags{
//                    for tag in tags{
//                        print("tags", tag["label"])
//                        print("tagstruct", self.tags)
//                        if let location = self.tags.index(where: { $0.title == tag["label"] }){
//
//                            print("location", location)
//                            self.tags.remove(at: location)
//                        }
//                    }
//                }
            })
        }
    }
    
//    @IBAction func optionsTapped(_ sender: UIBarButtonItem) {
//        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        alert.addAction(UIAlertAction(title: "Save Photo to phone", style: .default, handler: { _ in
////            UIImageWriteToSavedPhotosAlbum(self.selectedImage, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
//        }))
//
//        alert.addAction(UIAlertAction(title: "Delete Post", style: .default, handler: { _ in
//            //Add Delete logic here.
//        }))
//
//        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
//
//        self.present(alert, animated: true, completion: nil)
//    }
    

    

}



extension imageInfoViewController: UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    func saveTagsHandler() {
        guard let user = user else { return }
        let tagsRef = APIManger.shared.databaseRef.child(Constants.Database.tags).child(user.uid).childByAutoId()
        tagsRef.setValue(["tag": addTag.text])
        addTag.text = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print(textField)
        if textField == imageTitle {
            textField.resignFirstResponder()
        } else if textField == addTag {
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
        if tags[indexPath.item].isSelected {
            cell.backgroundColor = .black
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let cell = tableView.cellForRow(at: indexPath)
        if (cell?.accessoryType == UITableViewCell.AccessoryType.checkmark){
            tags[indexPath.item].isSelected = false;
            cell!.accessoryType = UITableViewCell.AccessoryType.none
        }else{
            tags[indexPath.item].isSelected = true;
            cell!.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
    }

}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
