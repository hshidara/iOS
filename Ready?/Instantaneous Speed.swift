//
//  Instantaneous Speed.swift
//  Ready?
//
//  Created by Hidekazu Shidara on 9/16/15.
//  Copyright (c) 2015 Hidekazu Shidara. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class Instantaneous_Speed: UIViewController, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    // You need to info.plist this before you use it.
    
    @IBOutlet weak var speedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = 5
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.activityType = .Fitness
        self.locationManager.startUpdatingLocation()
//        speedLabel.text = locationManager.location.speed.description
    }
    
    override func viewWillAppear(animated: Bool) {
        speedLabel.text = "...Loading Speed..."
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error:" + error.localizedDescription)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last
//        let mph = newLocation.speed * 3.6 * 2.23693629
        let mph = newLocation!.speed * 26.8224
//        let minPerMile = mph/60
//        let milePace = String(format: "0.2f",minPerMile)
//        speedLabel.text = "Your Pace is \(minPerMile) Mile Pace"
        
        if (mph !=  Double.infinity) {
            let intOfMPH = Int(mph)
            let percent = mph - Double(intOfMPH)
            
            let minutes = percent*60
            
            _ = String(format: "%.2f", mph)
            
            let betterMinutes = String(format:  "%.0f", minutes)
            
            speedLabel.text = "Pace: \(intOfMPH):\(betterMinutes) Minutes per Mile Pace"
        }
        else if mph.isSignMinus{
            speedLabel.text = "0:00"
        }
        else{
            speedLabel.text = "0:00"
        }
    }
}
