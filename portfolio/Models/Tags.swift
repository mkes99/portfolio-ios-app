//
//  Tags.swift
//  portfolio
//
//  Created by Formative Mini on 9/24/18.
//  Copyright © 2018 Formative Web Solutions. All rights reserved.
//

import Foundation
import Firebase

class TagModel {
    var title: String?
    var value: String?
    var timestamp: Int?
    
    static var blockList: [TagModel] = []
}

extension TagModel {
    static func transformUser(dict: [String: Any], key: String) -> TagModel {
        let tag = TagModel()
        tag.title = dict["tag"] as? String
        tag.timestamp = dict["timestamp"] as? Int
        tag.value = key
        
        return tag
    }
}
