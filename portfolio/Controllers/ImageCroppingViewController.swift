//
//  ImageCroppingViewController.swift
//  portfolio
//
//  Created by Formative Mini on 10/16/18.
//  Copyright © 2018 Formative Web Solutions. All rights reserved.
//

import UIKit

class ImageCroppingViewController: UIViewController, UIGestureRecognizerDelegate{
    
    var imageToBeCropped: UIImage?

    @IBOutlet weak var imageView: UIImageView!
    
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var cropSquare: UIView!
    
    enum Edge {
        case topLeft, topRight, bottomLeft, bottomRight, none
    }
    
    var edgeSize: CGFloat = 44.0
    
    var currentEdge: Edge = .none
    var touchStart = CGPoint.zero

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
       
        guard let image = imageToBeCropped else {
            return
        }
        
        imageView.image = image
       
        
        cancelButton.tintColor = .white
        saveButton.tintColor = .white
        navigationItem.titleView?.tintColor = .white
        

        
        cropSquare = CropFrame(frame: CGRect(x: view.frame.width/2, y: view.frame.height/2, width: 200, height: 200))
        self.view.addSubview(cropSquare)
        
       
        
        
//        let scrollViewSize = scrollView.bounds.size
//
//        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
//        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
//
//        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    
//        setImageToCrop(image: image)
    }
    
//    func resizeToBoundingSquare(sourceImage: UIImage, boundingSquareSideLength: CGFloat) {
//        let imgScale = sourceImage.size.width < sourceImage.size.height ? boundingSquareSideLength / sourceImage.size.width : boundingSquareSideLength / sourceImage.size.height
//
//        let scaleTransform = CIFilter(name: "CILanczosScaleTransform")
//        scaleTransform!.setValue(CIImage(image: sourceImage), forKey: "inputImage")
//        scaleTransform!.setValue(imgScale, forKey: "inputScale")
//        scaleTransform!.setValue(1.0, forKey: "inputAspectRatio")
//
//        let outputImage = scaleTransform!.value(forKey: "outputImage") as! CIImage
//
//        let context = CIContext(options: nil)
//
//        let extent = outputImage.extent()
//        let xOffset = Int(extent.width) > NodeConstants.imageWidth ? (extent.width - boundingSquareSideLength) / 2 : 0
//        let yOffset = Int(extent.height) > NodeConstants.imageWidth ? (extent.height - boundingSquareSideLength) / 2 : 0
//
//        let scaledImage = UIImage(CGImage: context.createCGImage(outputImage, fromRect: CGRect(x: xOffset, y: yOffset, width: boundingSquareSideLength, height: boundingSquareSideLength)))!
//
//        var angle = 0.0;
//
//        if (sourceImage.imageOrientation == UIImageOrientation.Right) {
//            angle = 90.0
//        }
//        else if (sourceImage.imageOrientation == UIImageOrientation.Left) {
//            angle = -90.0
//        }
//        else if (sourceImage.imageOrientation == UIImageOrientation.Down) {
//            angle = 180
//        }
//        else if (sourceImage.imageOrientation == UIImageOrientation.Up) {
//            angle = 0.0
//
//        }
//    }
    
    
    
//    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//        return imageView
//    }
//
//
//    func setImageToCrop(image:UIImage){
//        imageView.image = image
//        imageWidth.constant = image.size.width
//        imageHeight.constant = image.size.height
//        let scaleHeight = scrollView.frame.size.width/image.size.width
//        let scaleWidth = scrollView.frame.size.height/image.size.height
//        scrollView.minimumZoomScale = max(scaleWidth, scaleHeight)
//        scrollView.zoomScale = max(scaleWidth, scaleHeight)
//    }


    
//    func crop(image:UIImage, cropRect:CGRect) {
//        UIGraphicsBeginImageContextWithOptions(cropRect.size, false, image.scale)
//        let origin = CGPoint(x: cropRect.origin.x * CGFloat(-1), y: cropRect.origin.y * CGFloat(-1))
//        image.draw(at: origin)
//        guard let result = UIGraphicsGetImageFromCurrentImageContext() else {
//            return
//        }
//        UIGraphicsEndImageContext();
//
//        imageView.image = result
//    }
    
//    func cropImage(image:UIImage, toRect rect:CGRect) -> UIImage? {
//        var rect = rect
////        rect.size.width = rect.width * image.scale
////        rect.size.height = rect.height * image.scale
//
//        guard let imageRef = image.cgImage?.cropping(to: rect) else {
//            return nil
//        }
//
//        let croppedImage = UIImage(cgImage: imageRef, scale: 1.0, orientation: image.imageOrientation)
//        return croppedImage
//    }
    
//    func cropImage(_ inputImage: UIImage, toRect cropRect: CGRect, viewWidth: CGFloat, viewHeight: CGFloat) -> UIImage? {
//        print("height", viewHeight)
//        print("width", viewWidth)
//        let imageViewScale = max(inputImage.size.width / viewWidth,
//                                 inputImage.size.height / viewHeight)
//
//        // Scale cropRect to handle images larger than shown-on-screen size
//        let cropZone = CGRect(x:cropRect.origin.x,
//                              y:cropRect.origin.y,
//                              width:cropRect.size.width,
//                              height:cropRect.size.height)
//
//        // Perform cropping in Core Graphics
//        guard let cutImageRef: CGImage = inputImage.cgImage?.cropping(to:cropZone)
//            else {
//                return nil
//        }
//
//        // Return image to UIImage
//        let croppedImage: UIImage = UIImage(cgImage: cutImageRef)
//        print("croppedImage", croppedImage)
//        return croppedImage
//    }
    
//    func cropToBounds(image: UIImage, width: CGFloat, height: CGFloat) -> UIImage {
//
//        let cgimage = image.cgImage!
//        let contextImage: UIImage = UIImage(cgImage: cgimage)
//        let contextSize: CGSize = contextImage.size
//        var posX: CGFloat = 0.0
//        var posY: CGFloat = 0.0
//        var cgwidth: CGFloat = width
//        var cgheight: CGFloat = height
//
//        // See what size is longer and create the center off of that
//        if contextSize.width > contextSize.height {
//            posX = ((contextSize.width - contextSize.height) / 2)
//            posY = 0
//            cgwidth = contextSize.height
//            cgheight = contextSize.height
//        } else {
//            posX = 0
//            posY = ((contextSize.height - contextSize.width) / 2)
//            cgwidth = contextSize.width
//            cgheight = contextSize.width
//        }
//
//        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
//
//        // Create bitmap image from context using the rect
//        let imageRef: CGImage = cgimage.cropping(to: rect)!
//
//        // Create a new image based on the imageRef and rotate back to the original orientation
//        let image: UIImage = UIImage(cgImage: imageRef)
//
//        return image
//    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        imageView.contentMode = cropSquare.contentMode
        imageView.clipsToBounds = true
//        let newImage = imageView.image!.scaled(to: cropSquare.bounds.size, scalingMode: .aspectFit)
//        let newImage = cropToBounds(image: imageView.image!, width: cropSquare.frame.size.width, height: cropSquare.frame.size.height)
//        let newImage = cropImage(imageView.image!, toRect: cropSquare.bounds, viewWidth: cropSquare.frame.size.width, viewHeight: cropSquare.frame.size.height)
////        let croppedImage = imageView.image!.crop(size: cropSquare.frame.size, offset: cropSquare.frame.origin)
        if let navController = UIStoryboard(name: "Preview", bundle: nil).instantiateInitialViewController() as? UINavigationController, let previewVC = navController.topViewController as? PreviewViewController {

            previewVC.previewImage = imageView.image
           
            self.present(navController, animated: true, completion: nil)
        }
    
    }

    
}
