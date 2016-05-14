//
//  filterTest.swift
//  Camera
//
//  Created by Hidekazu Shidara on 9/1/15.
//  Copyright (c) 2015 Hidekazu Shidara. All rights reserved.
//
//  Summary: not pretty, but it works. Basically set the topImage to be the image plus a filter, and it works perfectly.

import UIKit

class filterTest: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var topImage: UIImageView!
    @IBOutlet weak var bottomImage: UIImageView!
    @IBOutlet weak var scrollview: UIScrollView!
    let context = CIContext(options: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollview.pagingEnabled = true
        scrollview.bounces = true
        scrollview.alwaysBounceHorizontal = true
        scrollview.alwaysBounceVertical = true
        scrollview.backgroundColor = UIColor.clearColor()
        scrollview.delegate=self
        scrollview.contentSize=CGSizeMake(2*self.view.bounds.width, self.view.bounds.height)
        
        bottomImage.image = UIImage(named: "TankLeft.png")
        topImage.image = UIImage(named: "TankLeft.png")
//        topImage.alpha = 0.0 // see through level, 0 is clear
        
        applyMask(CGRectMake(self.view.bounds.width-scrollview.contentOffset.x, scrollview.contentOffset.y, scrollview.contentSize.width, scrollview.contentSize.height))
    }
    
    func tint(image: UIImage, color: UIColor){
////        let ciImage = CIImage(image: image)
//        let filter = CIFilter(name: "CIPhotoEffectMono")
//        
////        let colorFilter = CIFilter(name: "CIConstantColorGenerator")
////        let ciColor = CIColor(color: color)
////        colorFilter.setValue(ciColor, forKey: kCIInputColorKey)
////        let colorImage = colorFilter.outputImage
//        
//        filter.setValue(image, forKey: kCIInputImageKey)
////        filter.setValue(image, forKey: kCIInputBackgroundImageKey)
//        
//        return UIImage(CIImage: filter.outputImage)!
    }
    
    func applyMask(maskRect: CGRect!){
        let maskLayer: CAShapeLayer = CAShapeLayer()
        let path: CGPathRef = CGPathCreateWithRect(maskRect, nil)
        maskLayer.path=path
        topImage.layer.mask = maskLayer
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        print(scrollView.contentOffset.x)
//        scrollView.setContentOffset(CGPointMake(scrollView.contentOffset.x, 0), animated: false)  // caption moving lock
        applyMask(CGRectMake(self.view.bounds.width-scrollView.contentOffset.x, scrollView.contentOffset.y, scrollView.contentSize.width, scrollView.contentSize.height))
//        monoFilter()
        noirFilter()
    }
    
    func rainbowFilter(){
        let inputImage = CIImage(image: topImage.image!)
        
        // Create a random color to pass to a filter
        let randomColor = [kCIInputAngleKey: (Double(arc4random_uniform(314)) / 100)]
        
        // Apply a filter to the image
        let filteredImage = inputImage!.imageByApplyingFilter("CIHueAdjust", withInputParameters: randomColor)
        
        //Render the filtered image
        let renderedImage = context.createCGImage(filteredImage, fromRect: filteredImage.extent)
        
        // Reflect the change back to the interface
        topImage.image = UIImage(CGImage: renderedImage)
    }
    
    func monoFilter(){
        let originalImage = CIImage(image: topImage.image!)
        let filter = CIFilter(name: "CIPhotoEffectMono")
        filter!.setValue(originalImage, forKey: kCIInputImageKey)
        let context = CIContext(options: nil)
        let outputImage = context.createCGImage(filter!.outputImage!, fromRect: filter!.outputImage!.extent)
        let newImage = UIImage(CGImage: outputImage)
        topImage.image = newImage
    }
    
    func noirFilter(){
        let originalImage = CIImage(image: topImage.image!)
        let filter = CIFilter(name: "CIPhotoEffectNoir")
        filter!.setValue(originalImage, forKey: kCIInputImageKey)
        let context = CIContext(options: nil)
        let outputImage = context.createCGImage(filter!.outputImage!, fromRect: filter!.outputImage!.extent)
        let newImage = UIImage(CGImage: outputImage)
        topImage.image = newImage
    }
    
}
