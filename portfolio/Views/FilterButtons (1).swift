//
//  ButtonSubClasss.swift
//  portfolio
//
//  Created by Formative Mini on 11/3/18.
//  Copyright © 2018 Formative Web Solutions. All rights reserved.
//

import UIKit

class CustomButton: UIButton {
    var value: String?
    
    convenience init(label: String) {
        self.init(frame: .zero)
        self.value = label
    }
}
