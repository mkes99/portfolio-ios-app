//
//  UINavigationController+Helpers.swift
//  portfolio
//
//  Created by Mike on 12/27/18.
//  Copyright © 2018 Formative Web Solutions. All rights reserved.
//

import UIKit

extension UINavigationController {
    open override var shouldAutorotate: Bool {
        get {
            if let visibleVC = visibleViewController {
                return visibleVC.shouldAutorotate
            }
            return super.shouldAutorotate
        }
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        get {
            if let visibleVC = visibleViewController {
                return visibleVC.preferredInterfaceOrientationForPresentation
            }
            return super.preferredInterfaceOrientationForPresentation
        }
    }
}
