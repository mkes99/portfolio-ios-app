//
//  AVPlayerPreviewViewController.swift
//  portfolio
//
//  Created by Formative Mini on 10/15/18.
//  Copyright © 2018 Formative Web Solutions. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class AVPlayerPreviewViewController: UIViewController {

    var videoURL: URL!
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        self.view.backgroundColor = UIColor.gray
        player = AVPlayer(url: videoURL)
        guard player != nil else {
            return
        }
        
        let playerLayer = AVPlayerLayer(player: player)
        self.view.layer.addSublayer(playerLayer)
        playerLayer.frame = self.view.layer.bounds
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill

        
//
//        self.view.layer.addSublayer(playerController?.view)
//
//
//        self.addChild(playerController!)
//        self.view.addSubview(playerController!.view)
//        playerController!.view.frame = view.frame
//        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player!.currentItem)
        
//        let cancelButton = UIButton(frame: CGRect(x: 10.0, y: 10.0, width: 30.0, height: 30.0))
//        cancelButton.setImage(#imageLiteral(resourceName: "cancel"), for: UIControl.State())
//        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
//        view.addSubview(cancelButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player?.play()
        
    }
    
    @objc func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
//    @objc fileprivate func playerItemDidReachEnd(_ notification: Notification) {
//        if self.player != nil {
//            self.player!.seek(to: CMTime.zero)
//            self.player!.play()
//        }
//    }

}
