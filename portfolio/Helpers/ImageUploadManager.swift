//
//  imageUploadManager.swift
//  portfolio
//
//  Created by Formative Mini on 9/18/18.
//  Copyright © 2018 Formative Web Solutions. All rights reserved.
//

import Foundation
import Firebase

class ImageUploadManager {
    static let shared = ImageUploadManager()
    
    func uploadImage(imageToUpload: UIImage?, storageName: String, uid: String, progressBlock: @escaping (_ percentage: Float) -> Void, completion: @escaping (_ url: URL?, _ error: String?) -> Void) {
        
        let storageRef = Storage.storage().reference().child(storageName).child(uid).child("\(Date().timeIntervalSince1970)")
        
        if let image = imageToUpload, let imageData = image.jpegData(compressionQuality: 0.1){
            let uploadTask = storageRef.putData(imageData, metadata: nil, completion: {( metadata, error) in
                storageRef.downloadURL(completion: {( url, error) in
                    guard let downloadURL = url else {
                        completion(nil, error?.localizedDescription)
                        return
                    }
                    completion(downloadURL, nil)
                })
            })
            uploadTask.observe(.progress, handler: { (snapshot) in
                guard let progress = snapshot.progress else {
                    return
                }
                let percentage = (Float(progress.completedUnitCount) / Float(progress.totalUnitCount)) * 100
                progressBlock(percentage)
                
            })
        }
    }
}
