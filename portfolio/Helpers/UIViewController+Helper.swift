//
//  UIViewController+Helper.swift
//  portfolio
//
//  Created by Mike on 12/27/18.
//  Copyright © 2018 Formative Web Solutions. All rights reserved.
//

import UIKit

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
