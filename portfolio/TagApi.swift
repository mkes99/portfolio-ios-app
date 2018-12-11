//
//  TagApi.swift
//  portfolio
//
//  Created by Formative Mini on 9/24/18.
//  Copyright © 2018 Formative Web Solutions. All rights reserved.
//

import Foundation
import Firebase

class TagApi {
    var REF_TAGS = Database.database().reference().child("tags")
    
    func queryTags(withId uid: String, completion: @escaping (TagModel) -> Void) {
        REF_TAGS.child(uid).observe(.value, with: { snapshot in
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
        REF_TAGS.child(userId).observe(.value, with: { snapshot in
            let count = Int(snapshot.childrenCount)
            completion(count)
        })
    }
}

