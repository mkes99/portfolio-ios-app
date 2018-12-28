//
//  PreviewViewController.swift
//  portfolio
//
//  Created by Formative Mini on 10/14/18.
//  Copyright © 2018 Formative Web Solutions. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Firebase

protocol PreviewViewDelegate: AnyObject {
   func dismissPreview()
}

class PreviewViewController: UIViewController{
    weak var delegate: PreviewViewDelegate?
    
    var previewImage: UIImage?
    
    var videoURL: URL!
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    var imageTitle: String?
    var tags: [String]?
    var imageId: String?
    
    let portfolioRef = APIManger.shared.databaseRef.child(Constants.Database.posts)

    @IBOutlet weak var previewPhotoView: UIImageView!
    
    @IBOutlet weak var videoView: UIView!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var filterSaveButton: UIButton!
    @IBOutlet weak var filterCancelButton: UIButton!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var uploadingImage: UILabel!
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var progressView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set navController to hidden
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = .white
        
        // init progress bar
        progressBar.setProgress(0.0, animated: false)
        progressView.isHidden = true
        
        // init scrollView
        scrollView.isHidden = true
        filterSaveButton.isHidden = true
        filterCancelButton.isHidden = true
    
        // navbar button styling
        cancelButton.tintColor = .white
        shareButton.tintColor = .white
        
        deleteButton.isHidden = true
        if imageId != nil {
            deleteButton.isHidden = false
        }
        
        // set correct view for content loaded
        if videoURL != nil {
            previewPhotoView.isHidden = true
            videoView.isHidden = false
            player = AVPlayer(url: videoURL)
            guard player != nil else {
                return
            }
            
            let playerLayer = AVPlayerLayer(player: player)
            videoView.layer.addSublayer(playerLayer)
            playerLayer.frame = self.view.layer.bounds
            playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        } else {
            videoView.isHidden = true
            previewPhotoView.isHidden = false
            previewPhotoView.image = self.previewImage
            previewPhotoView.frame.size = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
            self.buildEffectFilters()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         if videoURL != nil {
            player?.play()
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var shouldAutorotate: Bool {
        return false
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
       self.uploadDoneMove()
    }
  
    @IBAction func shareButtonTapped(_ sender: Any) {
        handleSavingPost()
    }
    
    @IBAction func filterButtonTapped(_ sender: UIButton) {
        scrollView.isHidden = false
        filterSaveButton.isHidden = false
        filterCancelButton.isHidden = false
    }
    
    @IBAction func filterCancelButtonTapped(_ sender: UIButton) {
        previewPhotoView.image = previewImage
        scrollView.isHidden = true
        filterSaveButton.isHidden = true
        filterCancelButton.isHidden = true
    }
    
    @IBAction func saveTapped(_ sender: UIButton) {
        scrollView.isHidden = true
        filterSaveButton.isHidden = true
        filterCancelButton.isHidden = true
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "DELETE POST", message: "By selecting continue you will remove this post permantly from the application.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { _ in
            guard let user = UserManager.shared.CURRENT_USER else { return }
            self.portfolioRef.child(user.uid).child(self.imageId!).removeValue()
            self.uploadDoneMove()
        }))

        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
    func uploadDoneMove() {
        delegate?.dismissPreview()
    }
}

extension PreviewViewController: UIViewControllerTransitioningDelegate {
    @IBAction func tagsButtonTapped(_ sender: UIButton) {
        let imageInfoVC = UIStoryboard(name: "ImageInfo", bundle: nil).instantiateViewController(withIdentifier: "imageInfoViewController") as! imageInfoViewController
        imageInfoVC.delegate = self
        imageInfoVC.imageId = imageId
        imageInfoVC.modalPresentationStyle = .custom
        imageInfoVC.transitioningDelegate = self
        
        self.present(imageInfoVC, animated: true, completion: nil)
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return ThreeQuarterPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension PreviewViewController: ImageInfoViewDelegate{
    // delegate func to pass data from imageInfo view controller
    func sendData(title: String, selectedTags: [String]) {
        self.imageTitle = title
        self.tags = selectedTags
    }
}

extension PreviewViewController {
    // save post func
    func handleSavingPost() {
        let timestamp = Int(Date().timeIntervalSince1970)
        let descSort = timestamp * -1
        guard let imageToSave = self.previewPhotoView.image else {
            return
        }
        
        guard let user = UserManager.shared.CURRENT_USER else { return }
        
        let ratio = imageToSave.size.width / imageToSave.size.height
        
        var setValueDict = [String: Any]()
        
        if imageId != nil {
            setValueDict = ["updated" : timestamp]
            
            if let title = self.imageTitle, !title.isEmpty {
                setValueDict["title"] = title
            }
            
            if let tags = self.tags {
                setValueDict["tags"] = tags
            }
            
            portfolioRef.child(user.uid).child(imageId!).updateChildValues(setValueDict)
            
            uploadDoneMove()
            
        } else {
            UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil)
            ImageUploadManager.shared.uploadImage(imageToUpload: imageToSave, storageName: "portfolio_image", uid: user.uid,  progressBlock: { (percentage) in
                self.previewView.isHidden = true
                self.progressView.isHidden = false
                self.progressBar.setProgress(percentage, animated: true)
            }, completion: { (fileURL, error) in
                if (error != nil) {
                    let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
                    alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                guard let imageUrl = fileURL else {
                    print("There was no image to upload, please try again.")
                    return
                }
                
                setValueDict = ["portfolioImage" : imageUrl.absoluteString, "height" : imageToSave.size.height, "width" : imageToSave.size.width, "timestamp" : timestamp, "ratio" : ratio, "descSort" : descSort]
                
                if let title = self.imageTitle, !title.isEmpty {
                    setValueDict["title"] = title
                }
                
                if let tags = self.tags {
                    setValueDict["tags"] = tags
                }
                
                self.portfolioRef.child(user.uid).childByAutoId().setValue(setValueDict)
                
                self.uploadDoneMove()
            })
        }
    }
    

    
    func buildEffectFilters() {
        var filterNames = [
            "origional",
            "CIPhotoEffectChrome",
            "CIPhotoEffectFade",
            "CIPhotoEffectInstant",
            "CIPhotoEffectMono",
            "CIPhotoEffectNoir",
            "CIPhotoEffectProcess",
            "CIPhotoEffectTonal",
            "CIPhotoEffectTransfer",
            "CISepiaTone",
            "CIVignette",
            "CIVignetteEffect"
        ]
        
        var xCoord: CGFloat = 5
        let yCoord: CGFloat = 5
        let buttonWidth:CGFloat = 90
        let buttonHeight: CGFloat = 90
        let gapBetweenButtons: CGFloat = 10
        
        var itemCount = 0
        
        for i in 0..<filterNames.count {
            itemCount = i
            
            // Button properties
            let filterButton = UIButton(type: .custom)
            filterButton.frame = CGRect(x: xCoord, y: yCoord, width: buttonWidth, height: buttonHeight)
            filterButton.tag = itemCount
            filterButton.addTarget(self, action: #selector(filtersTapped), for: .touchUpInside)
            filterButton.layer.borderColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1 ).cgColor
            filterButton.layer.borderWidth = 2.0
            filterButton.layer.cornerRadius = filterButton.bounds.size.width / 2
            filterButton.isSelected = false
            filterButton.clipsToBounds = true
            
            let ciContext = CIContext(options: nil)
            guard let coreImage = CIImage(image: previewPhotoView.image!) else {
                continue
            }
            guard let filter = CIFilter(name: "\(filterNames[i])" ) else {
                continue
            }
            
            filter.setDefaults()
            filter.setValue(coreImage, forKey: kCIInputImageKey)
            let filteredImageData = filter.value(forKey: kCIOutputImageKey) as! CIImage
            let filteredImageRef = ciContext.createCGImage(filteredImageData, from: filteredImageData.extent)
            let imageForButton = UIImage(cgImage: filteredImageRef!, scale: previewImage!.scale, orientation: previewImage!.imageOrientation);
            filterButton.setBackgroundImage(imageForButton, for: .normal)
            // Add Buttons in the Scroll View
            xCoord +=  buttonWidth + gapBetweenButtons
            scrollView.addSubview(filterButton)
        } // END FOR LOOP
        
        // Resize Scroll View
        scrollView.contentSize = CGSize(width: buttonWidth * CGFloat(itemCount+2), height:  yCoord)
    }
    
    
    @objc func filtersTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        for button in scrollView.subviews {
            if button is UIButton && button != sender {
                (button as! UIButton).backgroundColor = .clear
                (button as! UIButton).isSelected = false
                (button as! UIButton).setTitle("", for: .normal)
            }
        }
        
        if sender.isSelected {
            sender.tintColor = .black
            sender.setTitle("✓", for: .normal)
            sender.setTitleColor(.blue, for: .normal)
            previewPhotoView.image = sender.backgroundImage(for: .normal)
        } else {
            sender.setTitle("", for: .normal)
            previewPhotoView.image = previewImage
        }
    }
    
    func handleImageInfo(tile: String, pickedTags: [String]) {
        imageTitle = title
        tags = pickedTags
    }
}

