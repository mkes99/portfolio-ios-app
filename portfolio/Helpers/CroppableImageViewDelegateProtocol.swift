//
//  CropView.swift
//  portfolio
//
//  Created by Formative Mini on 10/16/18.
//  Copyright © 2018 Formative Web Solutions. All rights reserved.
//

import Foundation


@objc protocol CroppableImageViewDelegateProtocol
{
    func haveValidCropRect(_: Bool)
}

