//
//  PostsManager.swift
//  portfolio
//
//  Created by Mike on 11/4/18.
//  Copyright © 2018 Formative Web Solutions. All rights reserved.
//

import Foundation
import Firebase

struct PostsManager {
    static let shared = PostsManager()
    
    let postReference = APIManger.shared.databaseRef.child(Constants.Database.posts)
    let tagReference = APIManger.shared.databaseRef.child(Constants.Database.tags)
    
    func queryPosts(withUserId uid: String, completion: @escaping (PostModel) -> Void) {
        postReference.child(uid).queryLimited(toLast: 20).observe(.value, with: { snapshot in
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
        postReference.child(uid).child(id).observeSingleEvent(of: DataEventType.value, with: { snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let post = PostModel.transformPostPhoto(dict: dict, key: snapshot.key)
                completion(post)
            }
        })
    }
    
    func queryTags(withId uid: String, completion: @escaping (TagModel) -> Void) {
        tagReference.child(uid).observe(.value, with: { snapshot in
            snapshot.children.forEach({ (s) in
                let child = s as! DataSnapshot
                if let dict = child.value as? [String: Any] {
                    let tag = TagModel.transformUser(dict: dict, key: child.key)
                    completion(tag)
                }
            })
        })
    }
    
    func fetchTagCount(userId: String, completion: @escaping (Int) -> Void) {
        tagReference.child(userId).observe(.value, with: { snapshot in
            let count = Int(snapshot.childrenCount)
            completion(count)
        })
    }
    
    
    
    
}
