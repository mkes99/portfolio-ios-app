//
//  photosApi.swift
//  portfolio
//
//  Created by Formative Mini on 9/15/18.
//  Copyright © 2018 Formative Web Solutions. All rights reserved.
//

import Foundation
import Firebase

class PostApi {
    var REF_POSTS = Database.database().reference().child("posts")
    func queryPosts(withUserId uid: String, completion: @escaping (PostModel) -> Void) {
        REF_POSTS.child(uid).queryLimited(toLast: 20).observe(.value, with: { snapshot in
            snapshot.children.forEach({ (s) in
                let child = s as! DataSnapshot
                if let dict = child.value as? [String: Any] {
                    let post = PostModel.transformPostPhoto(dict: dict, key: child.key)
                    completion(post)
                }
            })
        })
    }
    
    func queryPostWithId(withPostId id: String, userId uid: String, completion: @escaping (PostModel) -> Void) {
        REF_POSTS.child(uid).child(id).observeSingleEvent(of: DataEventType.value, with: { snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let post = PostModel.transformPostPhoto(dict: dict, key: snapshot.key)
                completion(post)
            }
        })
    }
}
