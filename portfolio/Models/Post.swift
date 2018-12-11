//
//  Photos.swift
//  portfolio
//
//  Created by Formative Mini on 9/15/18.
//  Copyright © 2018 Formative Web Solutions. All rights reserved.
//

import Foundation
import Firebase

class PostModel {
    var title: String?
    var photoUrl: String?
    var uid: String?
    var id: String?
    var height: CGFloat?
    var width: CGFloat?
    var ratio: CGFloat?
    var videoUrl: String?
    var timestamp: Int?
    var tags: [String]?
}

extension PostModel {
    static func transformPostPhoto(dict: [String: Any], key: String) -> PostModel {
        let post = PostModel()
        post.id = key
        post.title = dict["title"] as? String
        post.photoUrl = dict["portfolioImage"] as? String
        post.videoUrl = dict["videoUrl"] as? String
        post.uid = dict["uid"] as? String
        post.ratio = dict["ratio"] as? CGFloat
        post.timestamp = dict["timestamp"] as? Int
        post.height = dict["height"] as? CGFloat
        post.width = dict["width"] as? CGFloat
        post.tags = dict["tags"] as? [String]
        
        return post
    }
    
    static func transformPostVideo() {
        
    }
}
