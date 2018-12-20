//
//  Extentions.swift
//  portfolio
//
//  Created by Formative Mini on 9/15/18.
//  Copyright © 2018 Formative Web Solutions. All rights reserved.
//

import UIKit
import AVFoundation

let imageCache = NSCache<NSString, AnyObject>()

extension UIImageView {
    
    func loadImageUsingCacheWithUrlString(_ urlString: String) {
        
        self.image = nil
        
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as NSString) as? UIImage {
            self.image = cachedImage
            return
        }
        
        //otherwise fire off a new download
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            //download hit an error so lets return out
            if let error = error {
                print(error)
                return
            }
            
            DispatchQueue.main.async(execute: {
                
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                    
                    self.image = downloadedImage
                }
            })
            
        }).resume()
    }
}

extension UIViewController {
    func fetchUser() {
        UserManager.shared.observeCurrentUser(completion: { (user) in
            let titleView = UIView()
            titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
            
            let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            titleView.addSubview(containerView)
            
            let nameLabel = UILabel()
            
            containerView.addSubview(nameLabel)
            nameLabel.text = user.name
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
            nameLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
            nameLabel.textColor = .white
            
            if let profileImageUrl = user.profileImageUrl {
                let profileImageView = UIImageView()
                profileImageView.translatesAutoresizingMaskIntoConstraints = false
                profileImageView.contentMode = .scaleAspectFill
                profileImageView.layer.cornerRadius = 20
                profileImageView.clipsToBounds = true
                profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
                containerView.addSubview(profileImageView)
                
                profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
                profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
                profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
                profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
                
                nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
                nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
            }
            
            containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
            containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
            
            self.navigationItem.titleView = titleView
        })
    }
}

extension UITextField {
    func setupField() {
        let bottomLayer = CALayer()
        bottomLayer.frame = CGRect(x: 0, y: 29, width: 1000, height: 1.0)
        bottomLayer.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1).cgColor
        self.layer.addSublayer(bottomLayer)
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder!, attributes: [NSAttributedString.Key.foregroundColor: UIColor(white: 1.0, alpha: 0.6)])
        self.backgroundColor = UIColor.clear
        self.tintColor = UIColor.white
        self.textColor = UIColor.white
    }
}


//extension Array where Element: Hashable {
//    func uniqueArray() -> [Element] {
//        var addedDict = [Element: Bool]()
//
//        return filter {
//            addedDict.updateValue(true, forKey: $0) == nil
//        }
//    }
//
//    mutating func uniqueArray() {
//
//        self = self.uniqueArray()
//    }
//}


extension Array where Element: Equatable {
    mutating func removeDuplicates() {
        var result = [Element]()
        for value in self {
            print("value", value)
            if !result.contains(value) {
                result.append(value)
            }
        }
        self = result
    }
}


extension UIImage {
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
