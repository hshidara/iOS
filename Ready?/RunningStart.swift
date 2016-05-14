//
//  RunningStart.swift
//  Ready?
//
//  Created by Hidekazu Shidara on 9/21/15.
//  Copyright © 2015 Hidekazu Shidara. All rights reserved.
//  Total Walking calories Spent = (Body weight in pounds) x (0.53) x (Distance in miles)

import UIKit
import CoreData
import CoreLocation
import HealthKit
import MapKit

class RunningStart: UITableViewController, MenuTransitionManagerDelegate, CLLocationManagerDelegate {
//    let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

//    var managedObjectContext: NSManagedObjectContext?

//    var run: Run!
    let convert = conversionToString()

    private var menuTransitionManager = MenuTransitionManager()

    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
//    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var buttonCell: UITableViewCell!
    
    
    //  MARK: Cells
    @IBOutlet weak var cell_1: UITableViewCell!
    @IBOutlet weak var cell_2: UITableViewCell!
    @IBOutlet weak var cell_3: UITableViewCell!
    
    //  MARK: Saving to CoreData
    var time = Time()
//    var distance: Double?
    var fastestSpeed: CLLocationSpeed?
    var averageAltitude: Double?
    var highestAltitude: Double?
    var caloriesBurned: Double?
    //--------------------------
    
    var seconds = 0.0
    var distance = 0.0
    var startTime = NSTimeInterval()
    var mapView = MKMapView()

    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        _locationManager.activityType = .Fitness
        
        // Movement threshold for new events
        _locationManager.distanceFilter = 10.0
        return _locationManager
        }()
    
    lazy var locations = [CLLocation]()
    lazy var timer = NSTimer()

    // MARK: - IBActions

    @IBAction func didPressCancel(sender: UIButton) {
        dismiss()
    }
    
    @IBAction func didPressStop(sender: UIButton) {
        timer.invalidate()
    }
    
    // MARK: - Override functions

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestAlwaysAuthorization()
        mapView.hidden = true
        self.set()
        self.setCells()
    }
    
    override func viewWillAppear(animated: Bool) {
        seconds = 0.0
        distance = 0.0
        locations.removeAll(keepCapacity: false)
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "eachSecond:", userInfo: nil, repeats: true)
        startTime = NSDate.timeIntervalSinceReferenceDate()
        startLocationUpdates()
//        stopButton.hidden = true
//        stopButton.enabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let menuTableViewController = segue.destinationViewController as! RunningStop
        time = convert.getTime()
        // Assign animator
        self.menuTransitionManager.delegate = self
        menuTableViewController.transitioningDelegate = self.menuTransitionManager
//        menuTableViewController.FastestSpeedLabel.text  = convert.instantSpeedToString(fastestSpeed!)
//        menuTableViewController.averagePace             = paceLabel.text!
        menuTableViewController.fastestSpeed            = self.fastestSpeed
        menuTableViewController.distance                = self.distance
        menuTableViewController.time                    = self.startTime
        menuTableViewController.averageAltitude         = self.averageAltitude
        menuTableViewController.highestAltitude         = self.highestAltitude
//        menuTableViewController.mapView                 = self.mapView
        menuTableViewController.timeSet                 = time
        //        menuTableViewController.averageAltitudeLabel.text   =
        //        menuTableViewController.highestAltitudeLabel.text   =
//        menuTableViewController.reg                     = mapView.region
    }
    
    // MARK: - Regular Functions

    func setCells(){
        view.backgroundColor = UIColor(hex: "#4B79A1")
        cell_1.backgroundColor = UIColor(hex: "#4B79A1")
        cell_2.backgroundColor = UIColor(hex: "#4B79A1")
        cell_3.backgroundColor = UIColor(hex: "#4B79A1")
    }
    
    func set(){
        self.distance = 0.0
        self.fastestSpeed = CLLocationSpeed(1000000.0)
        self.averageAltitude = 0.0
        self.highestAltitude = 0.0
        self.caloriesBurned = 0.0
    }
    
    func eachSecond(timer: NSTimer) {
        seconds++
        updateTime()
        
        _ = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: distance)
        distanceLabel.text = convert.distanceToString(distance)

        paceLabel.text = convert.paceToString(seconds, distance: distance)
    }
    
    func updateTime() {        
        timeLabel.text = convert.timeToString(startTime)
    }
    
    func instantSpeed(loc: CLLocation){
        let newLocation = loc
        let mph = newLocation.speed * 26.8224
        self.checkSpeed(mph)
        self.speedLabel.text = convert.instantSpeedToString(mph)

        let alt = loc.altitude * 3.28084
        if self.averageAltitude == 0.0{
            self.averageAltitude = alt
        }
        else{
            self.averageAltitude = (alt + self.averageAltitude!)/2
        }
        
        if self.highestAltitude < alt{
            self.highestAltitude = alt
        }
//        let better = String(format: "%.1f", alt)
    }
    
    func startLocationUpdates() {
        // Here, the location manager will be lazily instantiated
        locationManager.startUpdatingLocation()
    }
    
    func checkSpeed(mph: CLLocationSpeed){
        if seconds > 30{
            if self.fastestSpeed > mph{
                self.fastestSpeed = mph
            }
        }
    }
    
    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
}

//// MARK: - MKMapViewDelegate
extension RunningStart: MKMapViewDelegate {
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer! {
        if !overlay.isKindOfClass(MKPolyline) {
            return nil
        }
        
        let polyline = overlay as! MKPolyline
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 3
        return renderer
    }
}

//// MARK: - CLLocationManagerDelegate
//extension RunningStart: CLLocationManagerDelegate {
extension RunningStart {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.instantSpeed(locations.last!)
        //    for location in locations as [CLLocation] {
        for location in (locations ) {
            let howRecent = location.timestamp.timeIntervalSinceNow
            
            if abs(howRecent) < 10 && location.horizontalAccuracy < 20 {
                //update distance
                if self.locations.count > 0 {
                    distance += location.distanceFromLocation(self.locations.last!)
                    
                    var coords = [CLLocationCoordinate2D]()
                    coords.append(self.locations.last!.coordinate)
                    coords.append(location.coordinate)
                    
                    let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500)
                    mapView.setRegion(region, animated: true)
                    stopButton.hidden = false
                    stopButton.enabled = true
                    mapView.addOverlay(MKPolyline(coordinates: &coords, count: coords.count))
                }
                
                //save location
                self.locations.append(location)
            }
        }
    }
}

