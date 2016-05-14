//
//  ViewController.swift
//  Camera
//
//  Created by Hidekazu Shidara on 8/23/15.
//  Copyright (c) 2015 Hidekazu Shidara. All rights reserved.
//
//

import UIKit
import AVFoundation
import AssetsLibrary
import MediaPlayer
import QuartzCore

class ViewController: UIViewController,AVCaptureFileOutputRecordingDelegate,AVCaptureAudioDataOutputSampleBufferDelegate, UITextFieldDelegate{
    
    var sessionQueue: dispatch_queue_t!
    
    @IBOutlet weak var takePic: UIButton!
    @IBOutlet weak var deletePic: UIButton!
    @IBOutlet weak var flipCamera: UIButton!
    @IBOutlet weak var caption: UIButton!
    @IBOutlet weak var cameraButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var cameraButtonHeight: NSLayoutConstraint!
    
    @IBOutlet weak var deletePicWidth: NSLayoutConstraint!
    @IBOutlet weak var deletePicHeight: NSLayoutConstraint!
    
    @IBOutlet weak var flipCameraWidth: NSLayoutConstraint!
    @IBOutlet weak var flipCameraHeight: NSLayoutConstraint!
    
    var picOrVideo:String = " "
    
//    @IBOutlet weak var previewView: AVCamPreviewView!
    @IBOutlet weak var saveToPhotos: UIButton!
    var captureSession = AVCaptureSession()
    var selectedDevice: AVCaptureDevice?
    var stillImageOutput: AVCaptureStillImageOutput?
    var movieOutput: AVCaptureMovieFileOutput?
    var audioOutput: AVCaptureAudioDataOutput?
    var image:UIImage = UIImage(named: "TankLeft.png")!
    var imageView: UIImageView = UIImageView()
    var err : NSError? = nil
    var videoOrientation:AVCaptureVideoOrientation? = nil
    var moviePlayer : MPMoviePlayerController?
    let captionField = UITextField()
    var player = MPMoviePlayerController()
    var vidURL = NSURL()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.captionField.delegate = self;
        
        let sessionQueue: dispatch_queue_t = dispatch_queue_create("session queue",DISPATCH_QUEUE_SERIAL)
        
        self.sessionQueue = sessionQueue
        
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        
        selectedDevice = findCameraWithPosition(.Back)
            if selectedDevice != nil{
//                setFocusFlash()
                startCapture()
//                processOrientationNotifications()
            }
            setButtons()
        let tapGesture = UITapGestureRecognizer(target: self, action: "Tap")  //Tap function will call when user tap on button
        let longGesture = UILongPressGestureRecognizer(target: self, action: "Long:") //Long function will call when user long press on button.
        longGesture.minimumPressDuration = 0.8
        tapGesture.numberOfTapsRequired = 1
        takePic.addGestureRecognizer(tapGesture)
        takePic.addGestureRecognizer(longGesture)
    }
    
    func Tap(){
        picOrVideo = "Pic"
        takePic.enabled = false
        dispatch_async(self.sessionQueue, {
            // Update the orientation on the still image output video connection before capturing.
            
            //            let videoOrientation =  (self.previewLayer! as AVCaptureVideoPreviewLayer).connection.videoOrientation
            self.videoOrientation =  (self.previewLayer! as AVCaptureVideoPreviewLayer).connection.videoOrientation
            self.stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo).videoOrientation = self.videoOrientation!
            
            // Flash set to Auto for Still Capture
            //            ViewController.setFlashMode(AVCaptureFlashMode.Auto, device: self.videoDeviceInput!.device)
            self.stillImageOutput!.captureStillImageAsynchronouslyFromConnection(self.stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo), completionHandler: {
                (imageDataSampleBuffer: CMSampleBuffer!, error: NSError!) in
                if error == nil {
                    let data:NSData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                    self.image = UIImage( data: data)!
                    self.editPic(self.image)
                }
                else{
                    print(error, terminator: "")
                }
            })
        })
    }
    
    func Long(sender: UIGestureRecognizer){
        let recordingImage = UIImage(named: "cameraButtonRecording.png")
        takePic.setImage(recordingImage, forState: UIControlState.Normal)
        if sender.state == UIGestureRecognizerState.Began{
        captureSession.beginConfiguration()
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        self.videoOrientation =  (self.previewLayer! as AVCaptureVideoPreviewLayer).connection.videoOrientation
        //        self.audioOutput!.connectionWithMediaType(AVMediaTypeVideo).videoOrientation = self.videoOrientation!
        self.movieOutput!.connectionWithMediaType(AVMediaTypeVideo).videoOrientation = self.videoOrientation!
            
        captureSession.commitConfiguration()
            UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.cameraButtonHeight.constant = 90
                self.cameraButtonWidth.constant = 90
                self.view.layoutIfNeeded()
                }, completion: nil)
            
        dispatch_async(self.sessionQueue, {
            if !self.movieOutput!.recording{
                //                self.lockInterfaceRotation = true
                if UIDevice.currentDevice().multitaskingSupported {
                    //                    self.backgroundRecordId = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({})
                }
                // Turning OFF flash for video recording
                //                ViewController.setFlashMode(AVCaptureFlashMode.Off, device: self.videoDeviceInput!.device)
                
                let outputFilePath: String = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent( ("movie" as NSString).stringByAppendingPathExtension("mov")!)
                if self.movieOutput!.connectionWithMediaType(AVMediaTypeVideo).active == false {
                    self.movieOutput!.connectionWithMediaType(AVMediaTypeVideo).enabled = true
                }
                self.movieOutput!.startRecordingToOutputFileURL(NSURL.fileURLWithPath(outputFilePath), recordingDelegate: self)
            }
        })
        }
        else if sender.state == UIGestureRecognizerState.Ended{
            self.movieOutput!.stopRecording()
            
        }
    }
    
    func findCameraWithPosition(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        for device in devices as! [AVCaptureDevice] {
            if(device.position == position) {
                return device
            }
        }
        return nil
    }
    
    var previewLayer: AVCaptureVideoPreviewLayer? = nil
    
    func startCapture() {
        if let device = selectedDevice {
            
            let audioDevice: AVCaptureDevice = AVCaptureDevice.devicesWithMediaType(AVMediaTypeAudio).first as! AVCaptureDevice
            var audioDeviceInput: AVCaptureDeviceInput?
            
            if captureSession.canAddInput(AVCaptureDeviceInput(device: device)){
//                captureSession.addInput(AVCaptureDeviceInput(device: device, error: &err))
                captureSession.addInput(AVCaptureDeviceInput(device: selectedDevice))
            }
            if captureSession.canAddInput(AVCaptureDeviceInput(device: audioDevice)){
                captureSession.addInput(AVCaptureDeviceInput(device: audioDevice))
            }
            if err != nil {
                print("error: \(err?.localizedDescription)")
            }
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//            previewLayer?.frame = self.view.layer.frame
            previewLayer?.frame = self.view.bounds
            self.view.layer.addSublayer(previewLayer!)
            
//            self.previewView.session = captureSession
//            previewView.frameForAlignmentRect(CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
//            self.view.layer.addSublayer(previewView.layer)
            
            var stillImageOutput: AVCaptureStillImageOutput = AVCaptureStillImageOutput()
            movieOutput = AVCaptureMovieFileOutput()
            

            
            if captureSession.canAddOutput(stillImageOutput){
                stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
                captureSession.addOutput(stillImageOutput)
                self.stillImageOutput = stillImageOutput
            }
            if captureSession.canAddOutput(movieOutput){
                let maxDuration = CMTimeMakeWithSeconds(5, 600)
                movieOutput?.maxRecordedDuration = maxDuration
                captureSession.addOutput(movieOutput)
            }
            if captureSession.canAddInput(audioDeviceInput){
                
                captureSession.addInput(audioDeviceInput)
            }
            if captureSession.canAddOutput(audioOutput){
                captureSession.addOutput(audioOutput)
            }
            captureSession.startRunning()
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        if let layer = previewLayer {
            layer.frame = CGRectMake(0,0,size.width, size.height)
        }
    }
    
    var observer:NSObjectProtocol? = nil;
    
    func processOrientationNotifications() {
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
        observer = NSNotificationCenter.defaultCenter().addObserverForName(UIDeviceOrientationDidChangeNotification, object: nil, queue: NSOperationQueue.mainQueue()) { [unowned self](notification: NSNotification!) -> Void in
            if let layer = self.previewLayer {
                switch UIDevice.currentDevice().orientation {
                case .LandscapeLeft: layer.connection.videoOrientation = .LandscapeRight
                case .LandscapeRight: layer.connection.videoOrientation = .LandscapeLeft
                default: layer.connection.videoOrientation = .Portrait
                }
            }
        }
    }
    
    deinit {
        // Cleanup
        if observer != nil {
            NSNotificationCenter.defaultCenter().removeObserver(observer!)
        }
        
        UIDevice.currentDevice().endGeneratingDeviceOrientationNotifications()
    }
    
    func setFocusFlash(){
        if (selectedDevice?.isFocusModeSupported(AVCaptureFocusMode.ContinuousAutoFocus) != nil){
            selectedDevice?.isFocusModeSupported(.ContinuousAutoFocus)
        }
        if (selectedDevice?.isExposureModeSupported(.ContinuousAutoExposure) != nil) {
            selectedDevice?.isExposureModeSupported(.ContinuousAutoExposure)
        }
        if (selectedDevice?.isFlashModeSupported(.Auto) != nil){
            selectedDevice?.isFlashModeSupported(.Auto)
        }
        if (selectedDevice?.hasTorch == true){
            if (selectedDevice?.isTorchModeSupported(.Auto) != nil){
                selectedDevice?.isTorchModeSupported(.Auto)
            }
        }
        if (selectedDevice?.isWhiteBalanceModeSupported(.ContinuousAutoWhiteBalance) != nil){
            selectedDevice?.isWhiteBalanceModeSupported(.ContinuousAutoWhiteBalance)
        }
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        picOrVideo = "Video"
//        record.enabled = true
        if(error != nil){
            print(error, terminator: "")
        }
//        self.lockInterfaceRotation = false
        
        // Note the backgroundRecordingID for use in the ALAssetsLibrary completion handler to end the background task associated with this recording. This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's -isRecording is back to NO — which happens sometime after this method returns.
        
//        let backgroundRecordId: UIBackgroundTaskIdentifier = self.backgroundRecordId
//        self.backgroundRecordId = UIBackgroundTaskInvalid
        
//        let path = NSBundle.mainBundle().pathForResource("", ofType:"m4v")
//        let url = NSURL.fileURLWithPath(path!)
        
        moviePlayer = MPMoviePlayerController(contentURL: outputFileURL)
        
            player = moviePlayer!
            player.view.frame = self.view.bounds
            player.controlStyle = .None
            player.repeatMode = .One
            player.prepareToPlay()
            player.scalingMode = .AspectFill
            self.view.addSubview(player.view)
        vidURL = outputFileURL
        setEditButtonsPic()
        self.cameraButtonHeight.constant = 80
        self.cameraButtonWidth.constant = 80
        let regularImage = UIImage(named: "cameraButton.png")
        takePic.setImage(regularImage, forState: UIControlState.Normal)
    }
    
    func editPic(image: UIImage){
        imageView.image = image
        imageView.frame = self.view.frame
        self.view.addSubview(imageView)
        imageView.sendSubviewToBack(imageView)
        self.setEditButtonsPic()
    }
    
    func setEditButtonsPic(){
        self.deletePic.hidden = false
        self.saveToPhotos.hidden = false
        self.caption.hidden = false
        self.deletePic.enabled = true
        self.saveToPhotos.enabled = true
        self.caption.enabled = true
        
        caption.superview?.bringSubviewToFront(caption)
        saveToPhotos.superview?.bringSubviewToFront(saveToPhotos)
        deletePic.superview?.bringSubviewToFront(deletePic)
        
        self.takePic.hidden = true
        self.flipCamera.hidden = true
        self.takePic.enabled = false
        self.flipCamera.enabled = false
    }
    
    func resetButtons(){
        self.deletePic.hidden = true
        self.saveToPhotos.hidden = true
        self.caption.hidden = true
        self.deletePic.enabled = false
        self.saveToPhotos.enabled = false
        self.caption.enabled = false
        
        self.takePic.hidden = false
        self.flipCamera.hidden = false
        self.takePic.enabled = true
        self.flipCamera.enabled = true
        
        takePic.superview?.bringSubviewToFront(takePic) // Send button to front
        flipCamera.superview?.bringSubviewToFront(flipCamera)
    }
    
//    override func touchesBegan(touches: NSSet, withEvent event: UIEvent)
//    {
//        self.view.endEditing(true)
//        
//        if captionField.text == "" {
//            captionField.removeFromSuperview()
//        }
//        else{
//            if imageView.image != nil {
//                imageView.layer.addSublayer(captionField.layer)
//            }
//            else {
//                self.view.addSubview(captionField)
//                captionField.bringSubviewToFront(captionField)
//            }
//        }
//    }
    
    @IBAction func didPressCaption(sender: UIButton) {

        captionField.frame = CGRectMake(self.view.bounds.width/2, self.view.bounds.height/2, self.view.bounds.width, 40)
        captionField.backgroundColor = UIColor.blackColor()
        captionField.textColor = UIColor.whiteColor()
        captionField.tintColor = UIColor.blueColor()
        captionField.alpha = 0.6 // Transparency
        captionField.textAlignment = NSTextAlignment.Center
        captionField.becomeFirstResponder()
        
        if imageView.image != nil {
            self.imageView.addSubview(captionField)
            captionField.bringSubviewToFront(captionField)
        }
        else {
            self.view.addSubview(captionField)
            captionField.bringSubviewToFront(captionField)
        }
        
        let widthConstraint = NSLayoutConstraint(item: captionField, attribute: .Width, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 250)
        captionField.addConstraint(widthConstraint)
        
        let heightConstraint = NSLayoutConstraint(item: captionField, attribute: .Height, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 100)
        captionField.addConstraint(heightConstraint)
        
        let xConstraint = NSLayoutConstraint(item: captionField, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)
        
        let yConstraint = NSLayoutConstraint(item: captionField, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1, constant: 0)
        
        self.view.addConstraint(xConstraint)
        self.view.addConstraint(yConstraint)
        
    }
    
    @IBAction func didPressSaveToPhotos(sender: UIButton) {
        self.view.endEditing(true)
        
        if imageView.image != nil {
            imageView.layer.addSublayer(captionField.layer)
            UIGraphicsBeginImageContext(self.view.bounds.size)
            imageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            let library:ALAssetsLibrary = ALAssetsLibrary()
            let orientation: ALAssetOrientation = ALAssetOrientation(rawValue: image.imageOrientation.rawValue)!
            library.writeImageToSavedPhotosAlbum(image.CGImage, orientation: orientation, completionBlock: nil)
        }
        else {
            player.stop()
            player.view.layer.addSublayer(captionField.layer)
            UIGraphicsBeginImageContext(self.view.bounds.size)
            player.view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
            UIGraphicsEndImageContext()
            
            let composition = AVMutableComposition()
            
            vidURL = player.contentURL
            
            ALAssetsLibrary().writeVideoAtPathToSavedPhotosAlbum(vidURL, completionBlock: {
                (assetURL:NSURL!, error:NSError!) in
                if error != nil{
                    print(error, terminator: "")
                }
                else{
                    self.resetButtons()
                }
            })
//            NSFileManager.defaultManager().removeItemAtPath(expandedFilePath, error: nil)
            
            player.stop()
            self.player.view.removeFromSuperview()
        }
        
        print("save to album", terminator: "")
        imageView.image = nil
        self.captionField.removeFromSuperview()
        self.view.sendSubviewToBack(imageView)
        resetButtons()
        vidURL.removeAllCachedResourceValues()
        picOrVideo = " "
    }
    
    @IBAction func didPressDeletePic(sender: UIButton) {
        UIView.animateWithDuration(0.1, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 10, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.deletePicHeight.constant = 35
            self.deletePicWidth.constant = 35
            self.view.layoutIfNeeded()
            }, completion: {
                (value: Bool) in
                self.deletePicHeight.constant = 25
                self.deletePicWidth.constant = 25
                self.view.layoutIfNeeded()
        })
        
        self.view.endEditing(true)
        player.stop()
        self.captionField.removeFromSuperview()
        self.player.view.removeFromSuperview()
        imageView.image = nil
        resetButtons()
        vidURL.removeAllCachedResourceValues()
        self.view.sendSubviewToBack(imageView)
        picOrVideo = " "
    }
    
    @IBAction func didPressFlipCamera(sender: UIButton) {
        UIView.animateWithDuration(0.1, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 10, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.flipCameraHeight.constant = 40
            self.flipCameraWidth.constant = 45
            self.view.layoutIfNeeded()
            }, completion: {
                (value: Bool) in
                self.flipCameraHeight.constant = 30
                self.flipCameraWidth.constant = 35
                self.view.layoutIfNeeded()
        })
        
        dispatch_async(self.sessionQueue, {
            
            if self.selectedDevice ==  self.findCameraWithPosition(.Back){
                self.captureSession.beginConfiguration()
                let inputs = self.captureSession.inputs
                
                for input in inputs {
                    self.captureSession.removeInput(input as! AVCaptureInput)
                }
                let audioDevice: AVCaptureDevice = AVCaptureDevice.devicesWithMediaType(AVMediaTypeAudio).first as! AVCaptureDevice
                let audioDeviceInput: AVCaptureDeviceInput?
                self.selectedDevice =  self.findCameraWithPosition(.Front)

                if self.captureSession.canAddInput(AVCaptureDeviceInput(device: self.selectedDevice)){
                    self.captureSession.addInput(AVCaptureDeviceInput(device: self.selectedDevice))
                }
                if self.captureSession.canAddInput(AVCaptureDeviceInput(device: audioDevice)){
                    self.captureSession.addInput(AVCaptureDeviceInput(device: audioDevice))
                }
                self.captureSession.commitConfiguration()
            }
            else if self.selectedDevice ==  self.findCameraWithPosition(.Front){
                self.captureSession.beginConfiguration()

                let inputs = self.captureSession.inputs
                
                for input in inputs {
                    self.captureSession.removeInput(input as! AVCaptureInput)
                }
                let audioDevice: AVCaptureDevice = AVCaptureDevice.devicesWithMediaType(AVMediaTypeAudio).first as! AVCaptureDevice
                let audioDeviceInput: AVCaptureDeviceInput?
                self.selectedDevice =  self.findCameraWithPosition(.Back)
                
                if self.captureSession.canAddInput(AVCaptureDeviceInput(device: self.selectedDevice)){
                    self.captureSession.addInput(AVCaptureDeviceInput(device: self.selectedDevice))
                }
                if self.captureSession.canAddInput(AVCaptureDeviceInput(device: audioDevice)){
                    self.captureSession.addInput(AVCaptureDeviceInput(device: audioDevice))
                }
                self.captureSession.commitConfiguration()
            }
        })
    }
    
    func setButtons(){
        takePic.superview?.bringSubviewToFront(takePic) // Send button to front
        flipCamera.superview?.bringSubviewToFront(flipCamera)
        takePic.enabled = true
        flipCamera.enabled = true
        
        saveToPhotos.hidden = true
        deletePic.hidden = true
        caption.hidden = true
        self.saveToPhotos.enabled = false
        self.deletePic.enabled = false
        caption.enabled = false
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        textField.returnKeyType = .Done
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        if imageView.image != nil {
            imageView.layer.addSublayer(captionField.layer)
        }
        else {
            self.view.addSubview(captionField)
            captionField.bringSubviewToFront(captionField)
        }
        return false
    }
    
    override func didReceiveMemoryWarning() {
        imageView.image = nil
    }
    
    override func viewDidAppear(animated: Bool) {
        self.view.layoutIfNeeded()

    }
    
}

