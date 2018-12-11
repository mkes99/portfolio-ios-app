//
//  CustomCameraViewController.swift
//  portfolio
//
//  Created by Formative Mini on 10/14/18.
//  Copyright © 2018 Formative Web Solutions. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class CustomCameraViewController: UIViewController {
    
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var selectPhoto: UIButton!
    @IBOutlet weak var selectVideo: UIButton!
    @IBOutlet weak var switchCamera: UIButton!
    
    var typeOfShoot = "photo"
   
    var captureSession = AVCaptureSession()
    
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    
    var videoFileOutput:AVCaptureMovieFileOutput?
    
    var photoOutput: AVCapturePhotoOutput?
    
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var flashMode = AVCaptureDevice.FlashMode.off
    
    var capturedImage: UIImage?
    
    var isRecording = false
    
    var toggleCameraGestureRecognizer = UISwipeGestureRecognizer()
    
    var zoomInGestureRecognizer = UISwipeGestureRecognizer()
    var zoomOutGestureRecognizer = UISwipeGestureRecognizer()
    
    var pinchGesture = UIPinchGestureRecognizer()
    
    let ringLayer = CAShapeLayer()
    let diskLayer = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        selectPhoto.tintColor = .red

        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        startRunningCaptureSession()
        
        zoomInGestureRecognizer.direction = .right
        zoomInGestureRecognizer.addTarget(self, action: #selector(zoomIn))
        view.addGestureRecognizer(zoomInGestureRecognizer)

        // Zoom Out recognizer
        zoomOutGestureRecognizer.direction = .left
        zoomOutGestureRecognizer.addTarget(self, action: #selector(zoomOut))
        view.addGestureRecognizer(zoomOutGestureRecognizer)
        styleCaptureButton()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (context) -> Void in
            self.cameraPreviewLayer?.connection?.videoOrientation = self.transformOrientation(orientation: UIInterfaceOrientation(rawValue: UIApplication.shared.statusBarOrientation.rawValue)!)
            self.cameraPreviewLayer?.frame.size = self.view.frame.size
        }, completion: { (context) -> Void in
            
        })
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    @IBAction func isVideoTapped(_ sender: UIButton) {
        if typeOfShoot == "photo" {
            typeOfShoot = "video"
            selectPhoto.tintColor = .white
            selectVideo.tintColor = .red
            flashButton.isHidden = true
            diskLayer.fillColor = UIColor.red.cgColor
            setupCaptureSession()
            setupInputOutput()
            startRunningCaptureSession()
        }
    }
    
    @IBAction func isPhotoTapped(_ sender: UIButton) {
        if typeOfShoot == "video" {
            typeOfShoot = "photo"
            selectVideo.tintColor = .white
            selectPhoto.tintColor = .red
            flashButton.isHidden = false
            diskLayer.fillColor = UIColor.white.cgColor
            setupCaptureSession()
            setupInputOutput()
            startRunningCaptureSession()
        }
    }
    
    func styleCaptureButton() {
        captureButton.backgroundColor = .clear
        
        let outerRing = UIBezierPath(ovalIn: CGRect(x:3, y:3, width:75, height:75))
    
        ringLayer.path = outerRing.cgPath
        ringLayer.lineWidth = 4.0
        ringLayer.strokeColor = UIColor.white.cgColor
        ringLayer.fillColor = UIColor.clear.cgColor
        ringLayer.strokeEnd = 1.0
        
        captureButton.layer.addSublayer(ringLayer)
       
        diskLayer.path = UIBezierPath(roundedRect: CGRect(x:8, y:8, width:65, height:65), cornerRadius: 25).cgPath
        diskLayer.strokeColor = nil
        diskLayer.fillColor = UIColor.white.cgColor
        
        captureButton.layer.addSublayer(diskLayer)
        
    }
    
    func setupCaptureSession() {
        captureSession.beginConfiguration()
        if typeOfShoot == "photo" {
            captureSession.sessionPreset = AVCaptureSession.Preset.photo
        } else {
            captureSession.sessionPreset = AVCaptureSession.Preset.high
        }
         captureSession.commitConfiguration()
    }
    
    func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        let devices = deviceDiscoverySession.devices
        
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                backCamera = device
            } else if device.position == AVCaptureDevice.Position.front {
                frontCamera = device
            }
        }
        
        currentCamera = backCamera
    }
    
    func setupInputOutput() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            if(captureSession.canAddInput(captureDeviceInput) == true) {
                captureSession.addInput(captureDeviceInput)
            }
            if typeOfShoot == "photo" {
                photoOutput = AVCapturePhotoOutput()
                photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
                if videoFileOutput != nil {
                    captureSession.removeOutput(videoFileOutput!)
                }
                captureSession.addOutput(photoOutput!)
            } else {
                videoFileOutput = AVCaptureMovieFileOutput()
                if photoOutput != nil {
                    captureSession.removeOutput(photoOutput!)
                }
                captureSession.addOutput(videoFileOutput!)
            }
        } catch {
            print(error)
        }
        
    }
    
    func setupPreviewLayer() {
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = self.transformOrientation(orientation: UIInterfaceOrientation(rawValue: UIApplication.shared.statusBarOrientation.rawValue)!)
        cameraPreviewLayer?.frame = self.view.frame
        
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }
    
    func startRunningCaptureSession() {
        captureSession.startRunning()
    }
    
    func transformOrientation(orientation: UIInterfaceOrientation) -> AVCaptureVideoOrientation {
        switch orientation {
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        case .portraitUpsideDown:
            return .portraitUpsideDown
        default:
            return .portrait
        }
    }
    
    @objc func zoomInOut(sender: UIPinchGestureRecognizer) {
        guard let device = currentCamera else { return }
        
        if sender.state == .changed {
            
            let maxZoomFactor = device.activeFormat.videoMaxZoomFactor
            let pinchVelocityDividerFactor: CGFloat = 5.0
            
            do {
                
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }
                
                let desiredZoomFactor = device.videoZoomFactor + atan2(sender.velocity, pinchVelocityDividerFactor)
                device.videoZoomFactor = max(1.0, min(desiredZoomFactor, maxZoomFactor))
                
            } catch {
                print(error)
            }
        }
    }
    
    @IBAction func tookPhoto(_ sender: UIButton) {
        let centerPoint = CGPoint(x: captureButton.layer.frame.size.width / 1.85, y: captureButton.layer.frame.size.height / 1.85)
        if typeOfShoot == "photo" {
            let settings = AVCapturePhotoSettings()
            settings.flashMode = self.flashMode
            settings.isAutoStillImageStabilizationEnabled = true
            if let photoOutputConnection = self.photoOutput?.connection(with: AVMediaType.video) {
                photoOutputConnection.videoOrientation = self.transformOrientation(orientation: UIInterfaceOrientation(rawValue: UIApplication.shared.statusBarOrientation.rawValue)!)
            }
            self.photoOutput?.capturePhoto(with: settings, delegate: self)
        } else if !isRecording {
            isRecording = true
            let morph: CABasicAnimation = CABasicAnimation(keyPath: "path")
            morph.duration = 0.33
            morph.fromValue = circlePathWithCenter(center: centerPoint, radius: (captureButton.layer.frame.size.width - 8)/2).cgPath
            morph.toValue = squarePathWithCenter(center: centerPoint, side: centerPoint.x/1).cgPath
            morph.isRemovedOnCompletion = false
            morph.fillMode = CAMediaTimingFillMode.forwards
            diskLayer.add(morph, forKey: "morph disk to roundrect")
            
            let outputPath = NSTemporaryDirectory() + "output.mov"
            let outputFileURL = URL(fileURLWithPath: outputPath)
            videoFileOutput?.startRecording(to: outputFileURL, recordingDelegate: self)
        } else {
            isRecording = false
            
            let morph: CABasicAnimation = CABasicAnimation(keyPath: "path")
            morph.duration = 0.33
            morph.fromValue = squarePathWithCenter(center: centerPoint, side: centerPoint.x/1).cgPath
            morph.toValue = circlePathWithCenter(center: centerPoint, radius: (captureButton.layer.frame.size.width - 8)/2).cgPath
            morph.isRemovedOnCompletion = false
            morph.fillMode = CAMediaTimingFillMode.forwards
            diskLayer.add(morph, forKey: "morph roundrect to disk")
            
            videoFileOutput?.stopRecording()
        }
    }
    
    @IBAction func switchCameraTapped(_ sender: UIButton) {
        captureSession.beginConfiguration()
        
        // Change the device based on the current camera
        let newDevice = (currentCamera?.position == AVCaptureDevice.Position.back) ? frontCamera : backCamera
        
        // Remove all inputs from the session
        for input in captureSession.inputs {
            captureSession.removeInput(input as! AVCaptureDeviceInput)
        }
        
        // Change to the new input
        let cameraInput:AVCaptureDeviceInput
        do {
            cameraInput = try AVCaptureDeviceInput(device: newDevice!)
        } catch {
            print(error)
            return
        }
        
        if captureSession.canAddInput(cameraInput) {
            captureSession.addInput(cameraInput)
        }
        
        currentCamera = newDevice
        captureSession.commitConfiguration()
    }
    
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func flashButtonTapped(_ sender: UIButton) {
        if flashButton!.isSelected {
            flashMode = .off
            flashButton.tintColor = .white
            flashButton.isSelected = false
        } else {
            flashMode = .on
            flashButton.tintColor = .yellow
            flashButton.isSelected = true
        }
    }
}

extension CustomCameraViewController:  AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate{
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(){
            capturedImage = UIImage.init(data: imageData , scale: 1.0)
            if let navController = UIStoryboard(name: "Preview", bundle: nil).instantiateInitialViewController() as? UINavigationController, let previewVC = navController.topViewController as? PreviewViewController {
                print(previewVC)
                previewVC.previewImage = self.capturedImage
                self.present(navController, animated: true, completion: nil)
            }
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if (error != nil) {
            print("Error recording movie: \(error!.localizedDescription)")
        } else {
            if let navController = UIStoryboard(name: "Preview", bundle: nil).instantiateInitialViewController() as? UINavigationController, let previewVC = navController.topViewController as? PreviewViewController {
                print(previewVC)
                previewVC.videoURL = outputFileURL
                self.present(navController, animated: true, completion: nil)
            }
        }
    }
    
    func circlePathWithCenter(center: CGPoint, radius: CGFloat) -> UIBezierPath {
        let circlePath = UIBezierPath()
        circlePath.addArc(withCenter: center, radius: radius, startAngle: -.pi, endAngle: -.pi/2, clockwise: true)
        circlePath.addArc(withCenter: center, radius: radius, startAngle: -.pi/2, endAngle: 0, clockwise: true)
        circlePath.addArc(withCenter: center, radius: radius, startAngle: 0, endAngle: .pi/2, clockwise: true)
        circlePath.addArc(withCenter: center, radius: radius, startAngle: .pi/2, endAngle: .pi, clockwise: true)
        circlePath.close()
        return circlePath
    }
    
    func squarePathWithCenter(center: CGPoint, side: CGFloat) -> UIBezierPath {
        let squarePath = UIBezierPath()
        let startX = center.x - side / 2
        let startY = center.y - side / 2
        squarePath.move(to: CGPoint(x: startX, y: startY))
        squarePath.addLine(to: squarePath.currentPoint)
        squarePath.addLine(to: CGPoint(x: startX + side, y: startY))
        squarePath.addLine(to: squarePath.currentPoint)
        squarePath.addLine(to: CGPoint(x: startX + side, y: startY + side))
        squarePath.addLine(to: squarePath.currentPoint)
        squarePath.addLine(to: CGPoint(x: startX, y: startY + side))
        squarePath.addLine(to: squarePath.currentPoint)
        squarePath.close()
        return squarePath
    }
    
    @objc func zoomIn() {
        if let zoomFactor = currentCamera?.videoZoomFactor {
            if zoomFactor < 5.0 {
                let newZoomFactor = min(zoomFactor + 1.0, 5.0)
                do {
                    try currentCamera?.lockForConfiguration()
                    currentCamera?.ramp(toVideoZoomFactor: newZoomFactor, withRate: 1.0)
                    currentCamera?.unlockForConfiguration()
                } catch {
                    print(error)
                }
            }
        }
    }
    
    @objc func zoomOut() {
        if let zoomFactor = currentCamera?.videoZoomFactor {
            if zoomFactor > 1.0 {
                let newZoomFactor = max(zoomFactor - 1.0, 1.0)
                do {
                    try currentCamera?.lockForConfiguration()
                    currentCamera?.ramp(toVideoZoomFactor: newZoomFactor, withRate: 1.0)
                    currentCamera?.unlockForConfiguration()
                } catch {
                    print(error)
                }
            }
        }
    }
  
}
