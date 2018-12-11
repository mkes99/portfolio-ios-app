//
//  User.swift
//  portfolio
//
//  Created by Formative Mini on 9/11/18.
//  Copyright © 2018 Formative Web Solutions. All rights reserved.
//

import Foundation
import Firebase

class UserModel {
    var email: String?
    var profileImageUrl: String?
    var name: String?
    var id: String?
    
    static var blockList: [UserModel] = []
}

extension UserModel {
    static func transformUser(dict: [String: Any], key: String) -> UserModel {
        let user = UserModel()
        user.email = dict["email"] as? String
        user.profileImageUrl = dict["profileImage"] as? String
        user.name = dict["name"] as? String
        user.id = key
        return user
    }
}
