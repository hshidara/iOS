
//
//  Pedometer.swift
//  Ready?
//
//  Created by Hidekazu Shidara on 9/16/15.
//  Copyright (c) 2015 Hidekazu Shidara. All rights reserved.
//
//  Won't work without a 5s iphone, kaz's is 4s, I think you need mom's iphone.

import UIKit
import CoreMotion

class Pedometer: UIViewController {
    
    var circle = UIImageView()
    
    //  Screen size
    let screenRect = UIScreen.mainScreen().bounds
    
    var pedometer = CMPedometer()
    let activityManager = CMMotionActivityManager()
    var steps = UILabel()
    
    let manager = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setImage()
        setActivity()
    }
    
    func setImage(){
//        view.backgroundColor = UIColor.blueColor()
        
        circle = UIImageView(frame: CGRectMake(0,0,view.frame.width/2.0, view.frame.height/5))
        circle.frame.size.height = circle.frame.width
        circle.layer.cornerRadius = 95.0
        circle.backgroundColor = UIColor.blackColor()
        circle.alpha = 0.65
        circle.center = CGPointMake(self.view.center.x, self.view.center.y)
        view.addSubview(circle)
        
        let image = UIImageView(frame: CGRectMake(0,0,view.frame.width, view.frame.height))
        image.image = UIImage(named: "PedometerBackground")
        view.addSubview(image)
        view.sendSubviewToBack(image)
        setSteps()
    }
    
    func setSteps(){
        steps = UILabel()
        steps.frame = CGRectMake(0,0,view.frame.width/2.0, view.frame.height/5)
        steps.frame.size.height = steps.frame.width
        steps.textColor = UIColor.whiteColor()
        steps.textAlignment = NSTextAlignment.Center
        steps.font = UIFont(name: "AvenirNextCondensed-Heavy", size: 65.0)
        steps.backgroundColor = UIColor.clearColor()
        circle.addSubview(steps)
    }
        
    func setActivity(){
        manager.deviceMotionUpdateInterval = 0.01
        let cal = NSCalendar.currentCalendar()
        let comps = cal.components([NSCalendarUnit.Year, .Month, .Day, .Hour, .Minute, .Second], fromDate: NSDate())
        
        comps.hour = 0
        comps.minute = 0
        comps.second = 0
        let timeZone = NSTimeZone.systemTimeZone()
        cal.timeZone = timeZone
        
        _ = cal.dateFromComponents(comps)!
        
        self.activityManager.startActivityUpdatesToQueue(NSOperationQueue.mainQueue()) { (data) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if(data!.stationary == true){
                    //                        self.activityState.text = "Stationary"
                    //                        self.stateImageView.image = UIImage(named: "Sitting")
                } else if (data!.walking == true){
                    //                        self.activityState.text = "Walking"
                    //                        self.stateImageView.image = UIImage(named: "Walking")
                } else if (data!.running == true){
                    //                        self.activityState.text = "Running"
                    //                        self.stateImageView.image = UIImage(named: "Running")
                } else if (data!.automotive == true){
                    //                        self.activityState.text = "Automotive"
                }
            })
        }
        
        
        if(CMPedometer.isStepCountingAvailable()){
//            let fromDate = NSDate(timeIntervalSinceNow: -86400 * 7)
            self.pedometer.queryPedometerDataFromDate(NSDate(), toDate: NSDate(), withHandler: { (data, error) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if(error == nil){
                        print(data!.numberOfSteps)
                        self.steps.text = "\(data!.numberOfSteps)"
                    }
            })
            })
            
            self.pedometer.startPedometerUpdatesFromDate(NSDate(), withHandler: { (data, error) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if(error == nil){
                        print(data!.numberOfSteps)
                        if data!.numberOfSteps.integerValue - 15 >= Int(self.steps.text!){
                            self.steps.text = "\(data!.numberOfSteps)"
                        }
                        self.steps.text = "\(data!.numberOfSteps)"
                    }
                })
            })

            }

        }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
