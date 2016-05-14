//
//  AVCamPreviewView.swift
//  Camera
//
//  Created by Hidekazu Shidara on 8/24/15.
//  Copyright (c) 2015 Hidekazu Shidara. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation


class AVCamPreviewView: UIView{
    
    var session: AVCaptureSession? {
        get{
            return (self.layer as! AVCaptureVideoPreviewLayer).session;
        }
        set(session){
            (self.layer as! AVCaptureVideoPreviewLayer).session = session;
        }
    };
    
    
    
    override class func layerClass() ->AnyClass{
        return AVCaptureVideoPreviewLayer.self;
    }
    
    
    
    
    
    
    
    
    
}