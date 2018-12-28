//
//  PreviewPreviewViewController.swift
//  portfolio
//
//  Created by Formative Mini on 10/14/18.
//  Copyright © 2018 Formative Web Solutions. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Firebase

protocol PortfolioPreviewViewDelegate: AnyObject {
    func dismissPortfolioPreview()
}

class PortfolioPreviewViewController: UIViewController{
    weak var delegate: PortfolioPreviewViewDelegate?
    
    var previewImage: UIImage?
    
    var videoURL: URL!
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    
    
    @IBOutlet weak var previewPhotoView: UIImageView!
    
    @IBOutlet weak var videoView: UIView!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set navController to hidden
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = .white

        // navbar button styling
        cancelButton.tintColor = .white
     
        
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
            previewPhotoView.isHidden = false
            previewPhotoView.image = self.previewImage
            previewPhotoView.frame.size = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if videoURL != nil {
            player?.play()
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        UINavigationController.attemptRotationToDeviceOrientation()
        delegate?.dismissPortfolioPreview()
    }
}
