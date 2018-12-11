//
//  imagePicker.swift
//  portfolio
//
//  Created by Formative Mini on 9/28/18.
//  Copyright © 2018 Formative Web Solutions. All rights reserved.
//

import Foundation
import AVFoundation

class imagePicker: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    init(<#parameters#>) {
            
    }
    
    
    
    func selectPhoto(source: UIImagePickerController.SourceType){
        if UIImagePickerController.isSourceTypeAvailable(source){
            let myPickerController = UIImagePickerController()
            myPickerController.allowsEditing = true;
            myPickerController.delegate = self
            myPickerController.sourceType = source
            present(myPickerController, animated: true, completion: nil)
            
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        print("did Finish Picking Media")
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            if let editImageVC = UIStoryboard(name: "EditImage", bundle: nil).instantiateViewController(withIdentifier: "EditImageViewController") as? EditImageViewController {
                editImageVC.selectedImage = image
                if let navigator = navigationController {
                    navigator.pushViewController(editImageVC, animated: true)
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
}
