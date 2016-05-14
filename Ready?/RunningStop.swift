//
//  RunningStop.swift
//  Ready?
//
//  Created by Hidekazu Shidara on 9/21/15.
//  Copyright © 2015 Hidekazu Shidara. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import HealthKit
import MapKit

class RunningStop: UITableViewController {
//    var run: Run!
    var ath : Stats!
    var timeSet = Time()
    var convert = conversionToString()
    var records : RecordsData!
    
    //  MARK: Saving to Stats
    //    var averagePace:
    var time: NSTimeInterval?
    var distance: Double?
    var fastestSpeed: CLLocationSpeed?
    var averageAltitude: Double?
    var highestAltitude: Double?
    var caloriesBurned: Double?
    //--------------------------

    //  MARK: Saving to RecordsData
    var recordsHighestAltitude  = 0.0
    var recordsCalories         = 0.0
    var recordsLongestRun       = Time()
    
    //  MARK: Cells
    @IBOutlet weak var cell_1: UITableViewCell!
    @IBOutlet weak var cell_2: UITableViewCell!
    @IBOutlet weak var cell_3: UITableViewCell!
    @IBOutlet weak var cell_4: UITableViewCell!
    
    //--------------------------

    @IBOutlet weak var buttonCell: UITableViewCell!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var averagePaceLabel: UILabel!
    @IBOutlet weak var FastestSpeedLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var averageAltitudeLabel: UILabel!
    @IBOutlet weak var highestAltitudeLabel: UILabel!
    @IBOutlet weak var caloriesBurnedLabel: UILabel!
    
    var reg:MKCoordinateRegion?

    @IBAction func didPressSave(sender: UIButton) {
        self.saveStats(distance!)
        self.dismiss()
    }
    
    @IBAction func didPressDiscard(sender: UIButton) {
        self.dismiss()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        loadMap()
        setCell()
    }

    override func viewWillAppear(animated: Bool) {
        
        
//        averagePaceLabel.text       = averagePace
//        FastestSpeedLabel.text      = "nil"
        distanceLabel.text          = convert.distanceToString(self.distance!)
        timeLabel.text              = convert.timeToString(self.time!)
        averageAltitudeLabel.text   = convert.altitudeToString(self.averageAltitude!)
        highestAltitudeLabel.text   = convert.altitudeToString(self.highestAltitude!)
        caloriesBurnedLabel.text    = "nil"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func dismiss(){
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setCell(){
        view.backgroundColor = UIColor(hex: "#4B79A1")
        cell_1.backgroundColor = UIColor(hex: "#4B79A1")
        cell_2.backgroundColor = UIColor(hex: "#4B79A1")
        cell_3.backgroundColor = UIColor(hex: "#4B79A1")
        cell_4.backgroundColor = UIColor(hex: "#4B79A1")
    }
    
    func saveStats(miles: Double) {
        var numRuns = 0
//        let firstRun: NSDate?
        let totalSeconds = 0
        let totalMinuts = 0
        var totalHours = 0
//        var totalTime = 0.0
        var totalMiles = 0.0
//        var totalCalories = 0.0
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Stats")
        
        do {
            var results  =
            try managedContext!.executeFetchRequest(fetchRequest)
            ath = results[0] as! Stats
            print("******************************************************************")
            print(results)
            print(ath!.valueForKey("totalMiles"))
            totalMiles  = ath!.valueForKey("totalMiles")! as! Double
            numRuns     = ath!.valueForKey("numRuns")! as! Int
            totalHours  = ath!.valueForKey("totalTimeHours")! as! Int
            totalHours  = ath!.valueForKey("totalTimeMinutes")! as! Int
            totalHours  = ath!.valueForKey("totalTimeSeconds")! as! Int

//            totalTime   = (ath!.valueForKey("totalTime")! as? Double)!
            
            managedContext!.deleteObject(results[0] as! NSManagedObject)
            
            do {
                try managedContext!.save()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            } catch {
                print("sup")
            }
            
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        } catch {
            print("sup")
        }
        
        let entity =  NSEntityDescription.entityForName("Stats",
            inManagedObjectContext:managedContext!)
        
        let athlete = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext: managedContext)
        
//        athlete.setValue(totalTime + self.time!,forKey: "totalTime")
        timeSet = convert.addTime(timeSet, seconds: totalSeconds, minutes: totalMinuts, hours: totalHours)
        athlete.setValue(totalMiles + miles, forKey: "totalMiles")
        athlete.setValue(numRuns + 1,forKey: "numRuns")
        athlete.setValue(Int(timeSet.seconds!), forKey: "totalTimeSeconds")
        athlete.setValue(Int(timeSet.minutes!), forKey: "totalTimeMinutes")
        athlete.setValue(Int(timeSet.hours!), forKey: "totalTimeHours")
        
        if numRuns == 0 {
            athlete.setValue(NSDate(), forKey: "firstRun")
        }

        //4
        do {
            try managedContext!.save()
            
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
            print("sup")
        }
        self.dataFill()
    }

    // MARK: recordsData fetching
    func dataFill(){
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "RecordsData")
        
        var error: NSError?
        let count: Int = (managedContext?.countForFetchRequest(fetchRequest, error: &error))!
        
        if ((count == NSNotFound) || (count == 0)) {
            let entity =  NSEntityDescription.entityForName("RecordsData",
                inManagedObjectContext:managedContext!)
            
            let records = NSManagedObject(entity: entity!,
                insertIntoManagedObjectContext: managedContext)
            
            records.setValue(0.0, forKey: "highestAltitude")
            records.setValue(0.0,forKey: "longestRun")
            records.setValue(0.0,forKey: "mostCaloriesInARun")
            records.setValue(0,forKey: "mostStepsTakenAtOnce")
            
            do {
                try managedContext!.save()
                self.fetch(managedContext!,fetchRequest: fetchRequest)
                //                self.setCells()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            } catch {
                print("sup")
            }
        }
        else{
            self.fetch(managedContext!,fetchRequest: fetchRequest)
            //            self.setCells()
        }
    }
    
    func fetch(managedContext: NSManagedObjectContext, fetchRequest: NSFetchRequest){
        do {
            var results  =
            try managedContext.executeFetchRequest(fetchRequest)
            records = results[0] as! RecordsData
            
            recordsHighestAltitude  = records!.valueForKey("highestAltitude")! as! Double
            print(recordsHighestAltitude)
//            recordsCalories     = records!.valueForKey("numRuns")! as! Double
//            recordsLongestRun  = records!.valueForKey("totalTimeHours")! as! Double
            
            //Set New Values ++++++++++++++++++++++++++++++++++++++++++++++++++++++
            let entity =  NSEntityDescription.entityForName("RecordsData",
                inManagedObjectContext:managedContext)
            
            let recs = NSManagedObject(entity: entity!,
                insertIntoManagedObjectContext: managedContext)
            if recordsHighestAltitude < highestAltitude{
                recs.setValue(highestAltitude, forKey: "highestAltitude")
            }
//            recs.setValue(0.0,forKey: "longestRun")
//            recs.setValue(0.0,forKey: "mostCaloriesInARun")
//            recs.setValue(0,forKey: "mostStepsTakenAtOnce")
            
            do {
                try managedContext.save()
                //                self.setCells()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            } catch {
                print("sup")
            }
            
            //Set New Values ++++++++++++++++++++++++++++++++++++++++++++++++++++++
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        } catch {
            print("sup")
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
}

// MARK: - MKMapViewDelegate
//extension RunningStop: MKMapViewDelegate {
//}
