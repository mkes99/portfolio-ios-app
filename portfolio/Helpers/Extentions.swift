//
//  Extentions.swift
//  portfolio
//
//  Created by Formative Mini on 9/15/18.
//  Copyright © 2018 Formative Web Solutions. All rights reserved.
//

import UIKit
import AVFoundation





//extension Array where Element: Hashable {
//    func uniqueArray() -> [Element] {
//        var addedDict = [Element: Bool]()
//
//        return filter {
//            addedDict.updateValue(true, forKey: $0) == nil
//        }
//    }
//
//    mutating func uniqueArray() {
//
//        self = self.uniqueArray()
//    }
//}


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






