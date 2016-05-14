//
//  Records.swift
//  Ready?
//
//  Created by Hidekazu Shidara on 9/18/15.
//  Copyright (c) 2015 Hidekazu Shidara. All rights reserved.
//

import UIKit
import CoreData

class Records: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var records : RecordsData!
    var convert = conversionToString()

    //MARK: Data
//    var recordsHighestAltitude  = 0.0
//    var recordsCalories         = 0.0
    //===========
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setSelection()
        self.setNavBar()
        
        self.dataFill()
        // Do any additional setup after loading the view.
    }
    
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
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        } catch {
            print("sup")
        }
    }
    
    func setNavBar(){
        //customize
    }
    
    func setSelection(){
        tableView.allowsSelection = false
        tableView.allowsMultipleSelectionDuringEditing = false
        tableView.allowsMultipleSelection = false
        tableView.allowsSelectionDuringEditing = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section{
        case 0:
            return "Highest Altitude"
        case 1:
            return "Most Calories Burned in 1 Run"
        case 2:
            return "Longest Run"
        case 3:
            return "Most Steps Taken At Once"
        default:
            return ""
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0
    }
    
//    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let  headerCell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! UITableViewCell
//        
//        return headerCell
//    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) 
        cell.textLabel?.text = "\(records.valueForKey("highestAltitude")!)"
        return cell
    }

}
