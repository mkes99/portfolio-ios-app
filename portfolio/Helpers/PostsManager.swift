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
    let await = DispatchGroup()
    
    let postReference = APIManger.shared.databaseRef.child(Constants.Database.posts)
    
    func queryPosts(withUserId uid: String, completion: @escaping (PostModel) -> Void) {
        postReference.child(uid).queryOrdered(byChild: Constants.Database.timeStamp).queryLimited(toLast: 20).observeSingleEvent(of: .value, with: { snapshot in
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
    
    func queryPostAdded(userId uid: String, completion: @escaping (PostModel) -> Void) {
        postReference.child(uid).observe(.childAdded, with: { snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let post = PostModel.transformPostPhoto(dict: dict, key: snapshot.key)
                completion(post)
            }
        })
    }
    
    func queryPostPage(withId uid: String, start: Int, limit: UInt, completion: @escaping ([(PostModel)]) -> Void) {
        var postQuery = postReference.child(uid).queryOrdered(byChild: Constants.Database.descSort).queryLimited(toFirst: limit)
        
        if start < 0 {
            postQuery = postQuery.queryStarting(atValue: start, childKey: Constants.Database.descSort)
        }
        
        postQuery.observeSingleEvent(of: .value, with: { snapshot in
            
            var results: [PostModel] = []
            
            snapshot.children.forEach({ (s) in
                self.await.enter()
                let child = s as! DataSnapshot
                if let dict = child.value as? [String: Any] {
                    results.append(PostModel.transformPostPhoto(dict: dict, key: child.key))
                    self.await.leave()
                }
            })
            
            self.await.notify(queue: .main) {
                completion(results)
            }
        })
    }
    
    func fetchPostCount(userId: String, completion: @escaping (Int) -> Void) {
        postReference.child(userId).observe(.value, with: { snapshot in
            let count = Int(snapshot.childrenCount)
            completion(count)
        })
    }
}
