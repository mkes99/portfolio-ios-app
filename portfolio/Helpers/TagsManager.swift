//
//  TagsManager.swift
//  portfolio
//
//  Created by Formative Mini on 11/11/18.
//  Copyright © 2018 Formative Web Solutions. All rights reserved.
//

import Foundation
import Firebase

struct TagsManager {
    static let shared = TagsManager()
    let await = DispatchGroup()
    
    let tagReference = APIManger.shared.databaseRef.child(Constants.Database.tags)
    
    func queryTags(withId uid: String, completion: @escaping (TagModel) -> Void) {
        tagReference.child(uid).observeSingleEvent(of: .value, with: { snapshot in
            snapshot.children.forEach({ (s) in
                let child = s as! DataSnapshot
                if let dict = child.value as? [String: Any] {
                    let tag = TagModel.transformUser(dict: dict, key: child.key)
                    completion(tag)
                }
            })
        })
    }
    
    func queryTagsId(withId uid: String, tagId: String, completion: @escaping (TagModel) -> Void) {
        tagReference.child(uid).child(tagId).observeSingleEvent(of: DataEventType.value, with: { snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let tag = TagModel.transformUser(dict: dict, key: snapshot.key)
                completion(tag)
            }
        })
    }
    

    func queryTagsPage(withId uid: String, start: String, limit: UInt, completion: @escaping ([(TagModel)]) -> Void) {
        var tagQuery = tagReference.child(uid).queryOrdered(byChild: Constants.Database.tag).queryLimited(toFirst: limit)
        
        if !start.isEmpty {
            tagQuery = tagQuery.queryStarting(atValue: start, childKey: Constants.Database.tag)
        }
        
        tagQuery.observeSingleEvent(of: .value, with: { snapshot in
            var results: [TagModel] = []
            
            snapshot.children.forEach({ (s) in
                self.await.enter()
                let child = s as! DataSnapshot
                if let dict = child.value as? [String: Any] {
                    results.append(TagModel.transformUser(dict: dict, key: child.key))
                    self.await.leave()
                }
            })
            
            self.await.notify(queue: .main) {
                let sortedRes = results.sorted(by: {$0.title!.localizedCaseInsensitiveCompare($1.title!) == .orderedAscending })
                completion(sortedRes)
            }
        })
    }
    
    
    func queryPostTags(uid: String, tagsIds: [String], completion:  @escaping ([(TagModel)]) -> Void) {
        
        var results: [TagModel] = []
        
        tagsIds.forEach({ tagId in
            self.await.enter()
            queryTagsId(withId: uid, tagId: tagId, completion: { tag in
                results.append(tag)
                self.await.leave()
            })
        })
        
        self.await.notify(queue: .main) {
            let sortedRes = results.sorted(by: {$0.title!.localizedCaseInsensitiveCompare($1.title!) == .orderedAscending })
            completion(sortedRes)
        }
    }
    
    func saveTags(withUserId uid : String, tagText: String, timeStamp: Int, completion: @escaping (TagModel) -> Void){
        let formatedTagText = tagText.capitalized
        tagReference.child(uid).childByAutoId().setValue([Constants.Database.tag: formatedTagText, Constants.Database.timeStamp : timeStamp]){
            (error:Error?, snapshot) in
            if let error = error {
                print("Data could not be saved: \(error).")
            } else {
                self.queryTagsId(withId: uid, tagId: snapshot.key, completion: { (tag) in
                    completion(tag)
                })
            }
        }
    }
    
    func queryTagsAdded(userId uid: String, completion: @escaping (TagModel) -> Void) {
        tagReference.child(uid).observe(.childAdded, with: { snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let tag = TagModel.transformUser(dict: dict, key: snapshot.key)
                completion(tag)
            }
        })
    }
    
    func deleteTag(withTagId tagId: String, uid: String){
        tagReference.child(uid).child(tagId).removeValue()
    }
    
    func fetchTagCount(userId: String, completion: @escaping (Int) -> Void) {
        tagReference.child(userId).observe(.value, with: { snapshot in
            let count = Int(snapshot.childrenCount)
            completion(count)
        })
    }
}
