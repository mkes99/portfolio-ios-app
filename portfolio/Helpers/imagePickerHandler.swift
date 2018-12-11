//
//  imagePickerHandler.swift
//  portfolio
//
//  Created by Formative Mini on 9/28/18.
//  Copyright © 2018 Formative Web Solutions. All rights reserved.
//

import Foundation

//class imagePickerHandler: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
//
//    let sourceType: UIImagePickerController.SourceType
//    let picker = imagePickerController()
//
//    init(sourceType: UIImagePickerControllerSourceType) {
//        self.sourceType = sourceType
//        super.init()
//        self.picker.delegate = self
//    }
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        // Local variable inserted by Swift 4.2 migrator.
//        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
//
//        print("did Finish Picking Media")
//        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
//            if let editImageVC = UIStoryboard(name: "EditImage", bundle: nil).instantiateViewController(withIdentifier: "EditImageViewController") as? EditImageViewController {
//                editImageVC.selectedImage = image
//                if let navigator = navigationController {
//                    navigator.pushViewController(editImageVC, animated: true)
//                }
//            }
//        }
//        dismiss(animated: true, completion: nil)
//    }
//}
class ImagePickerHandler: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var delegate: MediaPickerPresenter?
    let sourceType: UIImagePickerControllerSourceType
    let picker = UIImagePickerController()
    
    init(sourceType: UIImagePickerControllerSourceType) {
        self.sourceType = sourceType
        super.init()
        self.picker.delegate = self
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let mediaType = info[UIImagePickerControllerMediaType] as? String {
            switch mediaType {
            case String(kUTTypeImage):
                if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                    self.delegate?.didSelectFromMediaPicker(withImage: selectedImage)
                }
            case String(kUTTypeImage), String(kUTTypeMovie), String(kUTTypeVideo):
                if let selectedMediaURL = info[UIImagePickerControllerMediaURL] as? NSURL {
                    self.delegate?.didSelectFromMediaPicker(withMediaUrl: selectedMediaURL)
                }
            default:
                break
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
