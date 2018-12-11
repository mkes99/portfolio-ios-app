//
//  Constants.swift
//  portfolio
//
//  Created by Mike on 11/4/18.
//  Copyright © 2018 Formative Web Solutions. All rights reserved.
//

import Foundation

enum Constants {
    
    enum Database {
        static let users = "users"
        static let posts = "posts"
        static let post = "post"
        static let tags = "tags"
        static let tag = "tag"
        static let timeStamp = "timestamp"
    }
    
//    var itemLimit = limit
//    
//    self.fetchTagCount(userId: uid, completion: { count in
//    if limit < count {
//    itemLimit = UInt(count)
//    }
//    })
    
    
    
    //            let items = snapshot.children.allObjects
    //            let myGroup = DispatchGroup()
    //            print("here", snapshot)
    //            var results: [TagModel] = []
    //
    //            for (_, item) in (items as! [DataSnapshot]).enumerated() {
    //                myGroup.enter()
    //                self.queryTagsId(withId: uid, tagId: item.key, completion: { (tag) in
    //                    results.append((tag))
    //                    myGroup.leave()
    //                })
    //            }
    //
    //            myGroup.notify(queue: .main) {
    //                results.sort(by: {$0.title! < $1.title!})
    //                completion(results)
    //            }
}
