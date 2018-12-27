//
//  Array+Helpers.swift
//  portfolio
//
//  Created by Mike on 12/27/18.
//  Copyright © 2018 Formative Web Solutions. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    mutating func removeDuplicates() {
        var result = [Element]()
        for value in self {
            print("value", value)
            if !result.contains(value) {
                result.append(value)
            }
        }
        self = result
    }
}
