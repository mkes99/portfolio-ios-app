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
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.isUserInteractionEnabled = false
        contentView.addSubview(imageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var frame = imageView.frame
        frame.size.height = self.frame.size.height
        frame.size.width = self.frame.size.width
        frame.origin.x = 0
        frame.origin.y = 0
        imageView.frame = frame
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var delegate: PostCollectionViewCellDelegate?

    var post: PostModel? {
        didSet {
            updateView()
        }
    }

    func updateView() {
        if let photoUrlString = post?.photoUrl {
            imageView.loadImageUsingCacheWithUrlString(photoUrlString)
        }
        
        let tapGestureForPhoto = UITapGestureRecognizer(target: self, action: #selector(self.photo_TouchUpInside))
        imageView.addGestureRecognizer(tapGestureForPhoto)
        imageView.isUserInteractionEnabled = true
    }

    @objc func photo_TouchUpInside() {
        guard let postId = post?.id else {
            return
        }

        delegate?.goToPreviewVC(postImage: imageView.image!, postId: postId)
    }
}
