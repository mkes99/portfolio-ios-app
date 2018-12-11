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
    
//    var thisTag: TagModel? {
//        didSet {
//            updateView()
//        }
//    }
//    
//    func updateView() {
//        
//        guard let title = thisTag?.title, let value = thisTag?.value else {
//            return
//        }
//        self.value = value
//        self.titleLabel?.text = title
//        self.titleLabel?.tintColor = .white
//        self.setTitle(title, for: .normal)
//        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
//        self.sizeToFit()
//       
//        self.layer.borderColor = UIColor.white.cgColor
//        self.layer.borderWidth = 2.0
//        self.layer.cornerRadius = self.frame.height / 2
//        self.isSelected = false
//        print("button width", self.titleLabel?.text)
//    }
}
