//
//  PostCollectionViewCell.swift
//  portfolio
//
//  Created by Formative Mini on 10/25/18.
//  Copyright © 2018 Formative Web Solutions. All rights reserved.
//

import UIKit

protocol PostCollectionViewCellDelegate {
    func goToPreviewVC(postImage: UIImage, postId: String)
}

class PostCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var collectionImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionImage.layer.cornerRadius = 8
        collectionImage.clipsToBounds = true
    }
    
    var delegate: PostCollectionViewCellDelegate?
    
    var post: PostModel? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        if let photoUrlString = post?.photoUrl {
            collectionImage.loadImageUsingCacheWithUrlString(photoUrlString)
        }
        
        let tapGestureForPhoto = UITapGestureRecognizer(target: self, action: #selector(self.photo_TouchUpInside))
        collectionImage.addGestureRecognizer(tapGestureForPhoto)
        collectionImage.isUserInteractionEnabled = true
        
    }
    
    @objc func photo_TouchUpInside() {
        guard let postId = post?.id else {
            return
        }
        
        delegate?.goToPreviewVC(postImage: collectionImage.image!, postId: postId)
    }
}
