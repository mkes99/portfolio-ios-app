//
//  ApiManager.swift
//  portfolio
//
//  Created by Mike on 11/4/18.
//  Copyright © 2018 Formative Web Solutions. All rights reserved.
//

import Foundation
import Firebase

struct APIManger {
    static let shared = APIManger()
    
    let databaseRef = Database.database().reference()
    
}
