//
//  Run.swift
//  Ready?
//
//  Created by Hidekazu Shidara on 9/20/15.
//  Copyright © 2015 Hidekazu Shidara. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import HealthKit
import CoreLocation

class Runner: UIViewController, CLLocationManagerDelegate {
    
    var managedObjectContext: NSManagedObjectContext?

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("RunningStart") as UIViewController!
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.backgroundColor = UIColor(hex: "#283E51")

        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.startUpdatingLocation()
        
        locationManager.requestWhenInUseAuthorization()
        self.mapView.mapType = MKMapType.HybridFlyover

        self.mapView.showsUserLocation = true
        self.mapView.zoomEnabled = false
        self.mapView.userInteractionEnabled = false
        self.mapView.rotateEnabled = false
        self.mapView.pitchEnabled = false
        
    }
    
    func setUserLocation(){
        let userLocation = mapView.userLocation
        
        let region = MKCoordinateRegionMakeWithDistance(
            userLocation.location!.coordinate, 2000, 2000)
        
        mapView.setRegion(region, animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        if self.mapView.userLocationVisible {
            let region = MKCoordinateRegionMakeWithDistance((self.mapView.userLocation.location?.coordinate)!, 400 , 400)
            self.mapView.setRegion(region, animated: false)
        }
        else{
            //Warning, no internet connection.
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //  MARK: Location Delegate Methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.latitude)
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        
        self.mapView.setRegion(region, animated: true)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
//          print("Errors: " + error.localizedDescription)
    }
}
