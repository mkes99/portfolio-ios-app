//
//  PassThroughView.swift
//  portfolio
//
//  Created by Formative Mini on 11/8/18.
//  Copyright © 2018 Formative Web Solutions. All rights reserved.
//

import UIKit

class PassThroughView: UIView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        print("Passing all touches to the next view (if any), in the view stack.")
        return false
    }
}
