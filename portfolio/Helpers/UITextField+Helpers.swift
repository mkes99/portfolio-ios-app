//
//  UITextField+Helpers.swift
//  portfolio
//
//  Created by Mike on 12/27/18.
//  Copyright © 2018 Formative Web Solutions. All rights reserved.
//

import UIKit

extension UITextField {
    func setupField() {
        let bottomLayer = CALayer()
        bottomLayer.frame = CGRect(x: 0, y: 29, width: 1000, height: 1.0)
        bottomLayer.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1).cgColor
        self.layer.addSublayer(bottomLayer)
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder!, attributes: [NSAttributedString.Key.foregroundColor: UIColor(white: 1.0, alpha: 0.6)])
        self.backgroundColor = UIColor.clear
        self.tintColor = UIColor.white
        self.textColor = UIColor.white
    }
}
