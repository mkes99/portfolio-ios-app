//
//  LoggedInViewController.swift
//  portfolio
//
//  Created by Formative Mini on 9/11/18.
//  Copyright © 2018 Formative Web Solutions. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

class LoggedInViewController: UIViewController {
    var selectedImage: UIImage?
    
    @IBOutlet weak var signOut: UIBarButtonItem!
    @IBOutlet weak var addImage: UIBarButtonItem!
    @IBOutlet weak var tagManager: UIBarButtonItem!
    
    @IBOutlet weak var collectionViewGrid: UICollectionView!
    @IBOutlet weak var collectionViewScroll: UICollectionView!
    
    @IBOutlet weak var noMatchLabel: UILabel!
    
    var posts: [PostModel] = []
    var filteredPosts: [PostModel] = []
    var filteredButtons: [CustomFilterButton] = []
    
    var tags: [TagModel] = []
    
    var user: User?
    
    var lastTagKey: String = ""
    var allTags: Bool = false
    var totalTagCount: Int = 0
    
    var lastPostKey: Int = 0
    var totalPostCount: Int = 0
    var allPosts: Bool = false
    
    let activityView = UIActivityIndicatorView(style: .whiteLarge)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set navController to hidden
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = .white
        
        if let currentUser = UserManager.shared.CURRENT_USER {
            user = currentUser
            self.fetchUser()
            
            PostsManager.shared.fetchPostCount(userId: currentUser.uid, completion: { count in
                self.totalPostCount = count
            })
            
            buildFilter()
            fetchPosts()
        }
        
        Auth.auth().addStateDidChangeListener() { auth, user in
            guard user != nil else {
                if let navController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as? UINavigationController {
                    self.present(navController, animated: true, completion: nil)
                }
                return
            }
        }
        
        // build collection view
        collectionViewGrid.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: "PostCollectionViewCell")
        collectionViewGrid.dataSource = self
        collectionViewGrid.delegate = self
        collectionViewGrid.contentInset = UIEdgeInsets(top: 0, left: 5, bottom: 5, right: 5)
        if let layout = collectionViewGrid.collectionViewLayout as? PinterestLayout {
            layout.delegate = self
        }
        
        collectionViewScroll.register(FilterCollectionViewCell.self, forCellWithReuseIdentifier: "FilterCollectionViewCell")
        collectionViewScroll.dataSource = self
        collectionViewScroll.delegate = self
        

        let layoutScroll = collectionViewScroll.collectionViewLayout as! UICollectionViewFlowLayout
        layoutScroll.estimatedItemSize = CGSize(width: 100, height: 50)
        
        noMatchLabel.isHidden = true
    
        self.view.addSubview(activityView)
        activityView.hidesWhenStopped = true
        activityView.center = self.view.center
        activityView.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionViewGrid.collectionViewLayout.invalidateLayout()
        collectionViewScroll.collectionViewLayout.invalidateLayout()
    }

    
    // add portfolio button
    @IBAction func addImageTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            alert.addAction(UIAlertAction(title: "Take photo", style: .default, handler: { _ in
                if let navController = UIStoryboard(name: "Camera", bundle: nil).instantiateInitialViewController() as? UINavigationController, let cameraVC = navController.topViewController as? CustomCameraViewController {
                    cameraVC.delegate = self
                    self.present(navController, animated: true, completion: nil)
                }
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Choose photo", style: .default, handler: { _ in
            let selectImage = UIImagePickerController()
            selectImage.allowsEditing = true;
            selectImage.delegate = self
            selectImage.sourceType = .photoLibrary
//            let previewVC = UIStoryboard(name: "Preview", bundle: nil).instantiateViewController(withIdentifier: "PreviewViewController") as UIViewController
//            previewVC.delegate = self
            self.present(selectImage, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // sign out button
    @IBAction func signoutButtonPressed(_ sender: UIBarButtonItem) {
        guard let user = user else { return }
        let onlineRef = UserManager.shared.getUserOnlineRef(user: user)
        onlineRef.removeValue { (error, _) in
            if let error = error {
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
                return
            }
            do {
                try Auth.auth().signOut()
            } catch (let error) {
                let alert = UIAlertController(title: "Auth sign out failed", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
   
}
extension LoggedInViewController {
    // get post for collection view
    func fetchPosts() {
        guard let user = user else { return }
        if allPosts == false {
            PostsManager.shared.queryPostPage(withId: user.uid, start: lastPostKey, limit: 10, completion: { (results) in

                if let lastPostValue = results.last?.descSort {
                    self.lastPostKey = lastPostValue
                }
                
                if results.count > 0 {
                    results.forEach({ (result) in
                        self.posts.append(result)
                    })
                } else {
                    self.allPosts = true
                }
                
                self.filteredPosts = self.posts
                self.collectionViewGrid.reloadData()
                self.activityView.stopAnimating()
                self.activityView.isHidden = true
            })
        }
    }
    
    // build filter buttons
    func buildFilter() {
        if allTags == false {
            guard let user = user else { return }
            TagsManager.shared.queryTagsPage(withId: user.uid, start: lastTagKey, limit: 8, completion: { (results) in
                
                if let lastTagValue = results.last?.title {
                    self.lastTagKey = lastTagValue
                }
                
                if results.count > 0 {
                    results.forEach({ (result) in
                        self.tags.append(result)
                    })
                } else {
                    self.allTags = true
                }
                self.collectionViewScroll.reloadData()
            })
        }
    }
    
    @objc func filtersButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            sender.backgroundColor = .white
            sender.setTitleColor(.black, for: .normal)
        } else {
            sender.backgroundColor = .clear
            sender.setTitleColor(.white, for: .normal)
        }
        
        let selectedTagIds = getSelectedButtons()
        
        filteredPosts = posts
        
        var matchingPosts: [PostModel] = []
        filteredPosts.forEach { post in
            let sharedTags = post.tags?.compactMap({ $0 }).filter({selectedTagIds.contains( $0 )})
            if let sharedTags = sharedTags, sharedTags.count > 0 {
                matchingPosts.append(post)
            }
        }
        
        collectionViewGrid.isHidden = false
        noMatchLabel.isHidden = true
        
        switch matchingPosts.count {
        case let post where post > 0 :
            filteredPosts = matchingPosts
        case 0:
            if selectedTagIds.count > 0 {
                collectionViewGrid.isHidden = true
                noMatchLabel.isHidden = false
                noMatchLabel.text = "There are no post that match your current query, please select another filter option."
            } else {
                fallthrough
            }
        default :
            filteredPosts = posts
        }
        self.collectionViewGrid.reloadData()
    }
    
    func getSelectedButtons() -> [String] {
        return filteredButtons.filter({ $0.isSelected }).compactMap({ $0.value })
    }
}

extension LoggedInViewController:  UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    // imagepicker controller
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            dismiss(animated: true, completion: {
                if let navController = UIStoryboard(name: "Preview", bundle: nil).instantiateInitialViewController() as? UINavigationController, let previewVC = navController.topViewController as? PreviewViewController {
                    previewVC.previewImage = image
                    self.present(navController, animated: true, completion: nil)
                }
            })
        }
    }
}

extension LoggedInViewController: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForImageAtIndexPath indexPath: IndexPath, withWidth: CGFloat) -> CGFloat {
        let post = filteredPosts[indexPath.row]
        let height: CGFloat =  withWidth / post.ratio!
        
        return height
    }
}

extension LoggedInViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == collectionViewScroll{
            let tagCount = tags.count
            return tagCount
        } else {
            let postCount = filteredPosts.count
            return postCount
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == collectionViewScroll{
            
            let filterCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollectionViewCell", for: indexPath) as! FilterCollectionViewCell
            if !tags.isEmpty {
                let tag = tags[indexPath.row]
                filterCell.filterTag = tag
                filterCell.delegate = self

            }
            
            return filterCell
        } else {
            let postCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCollectionViewCell", for: indexPath) as! PostCollectionViewCell
            if !filteredPosts.isEmpty {
                let post = filteredPosts[indexPath.row]
                postCell.post = post
                postCell.delegate = self
            }
            
            return postCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == collectionViewScroll {
            let tag = tags[indexPath.row]
            let width = tag.title!.size(withAttributes: [
                NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)
                ]).width
            return CGSize(width: width + CGFloat(tag.title!.count) + 60, height: 32)
        } else {
            return CGSize(width: 200, height: 200)
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffset: CGFloat?
        let maxOffset: CGFloat?
        
        if scrollView == collectionViewScroll {
            currentOffset = scrollView.contentOffset.x
            maxOffset = scrollView.contentSize.width - scrollView.frame.width
        } else {
            currentOffset = scrollView.contentOffset.y
            maxOffset = scrollView.contentSize.height - scrollView.frame.height
        }
        
        if maxOffset! - currentOffset! <= 40 {
            if scrollView == collectionViewScroll {
                buildFilter()
            } else {
                if allPosts != true {
                    activityView.startAnimating()
                    activityView.isHidden = false
                }
                fetchPosts()
            }
        }
    }
}

extension LoggedInViewController: PreviewViewDelegate {
    func dismissPreview() {
        //Clear collection views and reload with new data in proper order.
        filteredPosts.removeAll()
        posts.removeAll()
        lastPostKey = 0
        totalPostCount = 0
        allPosts = false
        
        tags.removeAll()
        lastTagKey = ""
        allTags = false
        totalTagCount = 0
        collectionViewGrid.reloadData()
        collectionViewScroll.reloadData()
        fetchPosts()
        buildFilter()
        
        dismiss(animated: true, completion: nil)
    }
}

extension LoggedInViewController: PostCollectionViewCellDelegate {
    func goToPreviewVC(postImage: UIImage, postId: String) {
        if let navController = UIStoryboard(name: "Preview", bundle: nil).instantiateInitialViewController() as? UINavigationController, let previewVC = navController.topViewController as? PreviewViewController {
            previewVC.previewImage = postImage
            previewVC.imageId = postId
            previewVC.delegate = self
            self.present(navController, animated: true, completion: nil)
        }
    }
}

extension LoggedInViewController: FilterCollectionViewCellDelegate {
    func filterPost(selectedTagIds: [String]) {
        filteredPosts = posts
        
        var matchingPosts: [PostModel] = []
        filteredPosts.forEach { post in
            let sharedTags = post.tags?.compactMap({ $0 }).filter({selectedTagIds.contains( $0 )})
            if let sharedTags = sharedTags, sharedTags.count > 0 {
                matchingPosts.append(post)
            }
        }
        
        collectionViewGrid.isHidden = false
        noMatchLabel.isHidden = true
        
        switch matchingPosts.count {
        case let post where post > 0 :
            filteredPosts = matchingPosts
        case 0:
            if selectedTagIds.count > 0 {
                collectionViewGrid.isHidden = true
                noMatchLabel.isHidden = false
                noMatchLabel.text = "There are no post that match your current query, please select another filter option."
            } else {
                fallthrough
            }
        default :
            filteredPosts = posts
        }
        
        self.collectionViewGrid.reloadData()
    }
}

extension LoggedInViewController: UIViewControllerTransitioningDelegate {
    @IBAction func tagManagerTapped(_ sender: UIBarButtonItem) {
        let imageInfoVC = UIStoryboard(name: "ImageInfo", bundle: nil).instantiateViewController(withIdentifier: "imageInfoViewController") as! imageInfoViewController
        imageInfoVC.modalPresentationStyle = .custom
        imageInfoVC.transitioningDelegate = self
        
        self.present(imageInfoVC, animated: true, completion: nil)
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return ThreeQuarterPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
