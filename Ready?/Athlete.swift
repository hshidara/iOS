//
//  Athlete.swift
//  
//http://uigradients.com/#DarkSkies
//  Created by Hidekazu Shidara on 9/18/15.
//
//[NSNumber numberWithDouble:myTimeInterval];
//
import CoreData
import UIKit

class Athlete: UITableViewController {

//    var athlete : NSManagedObject!
    var athlete : Stats!
    
    //  Screen size
//    let screenRect = UIScreen.mainScreen().bounds

    var convert = conversionToString()
    @IBOutlet weak var totalTime: UITableViewCell!
    @IBOutlet weak var totalMiles: UITableViewCell!
    @IBOutlet weak var totalCals: UITableViewCell!
    @IBOutlet weak var total: UITableViewCell!
    @IBOutlet weak var numRunsLabel: UILabel!
    @IBOutlet weak var firstRunDate: UILabel!
    
//    var totalTime = UITableViewCell()
//    var totalMiles = UITableViewCell()
//    var totalCals = UITableViewCell()
//    var numRunsLabel = UILabel()
//    var firstRunDate = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView = UITableView(frame: self.tableView.frame, style: .Grouped)
        self.setSelection()
        self.setTableView()
        
        navigationController?.navigationBar.backgroundColor = UIColor(hex: "#283E51")
        navigationController?.navigationBar.tintColor = UIColor(hex: "#283E51")
        
        total.backgroundColor = UIColor(hex: "#4B79A1")
        totalTime.backgroundColor = UIColor(hex: "#4B79A1")
        totalMiles.backgroundColor = UIColor(hex: "#4B79A1")
        totalCals.backgroundColor = UIColor(hex: "#4B79A1")
        
        self.view.backgroundColor = UIColor(hex: "#4B79A1")
        
        total.alpha = 0.50
        totalTime.alpha = 0.50
        totalMiles.alpha = 0.50
        totalCals.alpha = 0.50
        
        totalCals.detailTextLabel!.text = "not available"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Stats")
        
        var error: NSError?
        let count: Int = (managedContext?.countForFetchRequest(fetchRequest, error: &error))!

        if ((count == NSNotFound) || (count == 0)) {
            let entity =  NSEntityDescription.entityForName("Stats",
                inManagedObjectContext:managedContext!)
            
            let athlete = NSManagedObject(entity: entity!,
                insertIntoManagedObjectContext: managedContext)
            
            athlete.setValue(NSDate(), forKey: "firstRun")
            athlete.setValue(0.0,forKey: "numRuns")
            athlete.setValue(0.0,forKey: "totalTime")
            athlete.setValue(0.0,forKey: "totalCalories")
            athlete.setValue(0.0, forKey: "totalMiles")
            athlete.setValue(0, forKey: "totalTimeHours")
            athlete.setValue(0, forKey: "totalTimeMinutes")
            athlete.setValue(0, forKey: "totalTimeSeconds")
            
            do {
                try managedContext!.save()
                self.fetch(managedContext!,fetchRequest: fetchRequest)
                self.setCells()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            } catch {
                print("sup")
            }
        }
        else{
            self.fetch(managedContext!,fetchRequest: fetchRequest)
            self.setCells()
        }
    }
    
    func setTableView(){
//        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
//        self.tableView.registerClass(MyCell.self, forCellReuseIdentifier: "mycell")
    }
    
    func fetch(managedContext: NSManagedObjectContext, fetchRequest: NSFetchRequest){
        do {
            var results  =
            try managedContext.executeFetchRequest(fetchRequest)
            athlete = results[0] as! Stats
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        } catch {
            print("sup")
        }
    }
    
    func setCells(){
        self.totalMiles.detailTextLabel?.text = "\(athlete.valueForKey("totalMiles")!)"
        self.totalTime.detailTextLabel?.text = convert.brokenTimeToString(Int(athlete.valueForKey("totalTimeSeconds")! as! NSNumber), minutes: Int(athlete.valueForKey("totalTimeMinutes")! as! NSNumber), hours: Int(athlete.valueForKey("totalTimeHours")! as! NSNumber))
//        totalCals.detailTextLabel?.text = athlete.valueForKey("totalCalories") as? String
        self.numRunsLabel.text = "\(athlete.valueForKey("numRuns")!)"
        if "\(athlete.valueForKey("numRuns")!)" == "0"  {
            self.firstRunDate.text = "Has not run yet"
        }
        else{
            let formatter = NSDateFormatter()
            formatter.timeStyle = .MediumStyle
            self.firstRunDate.text = "\(formatter.stringFromDate((athlete.valueForKey("firstRun")!) as! NSDate))"
        }
    }
    
    func setSelection(){
        tableView.allowsSelection = false
        tableView.allowsMultipleSelectionDuringEditing = false
        tableView.allowsMultipleSelection = false
        tableView.allowsSelectionDuringEditing = false
    }
    
    func saveName(miles: Double) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity =  NSEntityDescription.entityForName("Stats",
            inManagedObjectContext:managedContext!)
        let athlete = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext: managedContext)
        
        athlete.setValue(miles, forKey: "totalMiles")
        
        do {
            try managedContext!.save()
            
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
            print("sup")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
//    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
//    {
//        switch(indexPath.row){
//        case 0:
//            return screenRect.height/2.5
//        case 1:
//            return screenRect.height/6
//        case 2:
//            return screenRect.height/6
//        case 3:
//            return screenRect.height/6
//        default:
//            return screenRect.height/6
//        }
//    }
    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
////        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
////        switch(indexPath.row){
////        case 0:
////            let cell = tableView.dequeueReusableCellWithIdentifier("mycell", forIndexPath: indexPath) as! MyCell
////            return cell
//////            case 1:
//////            case 2:
//////            case 3:
////        default:
////            let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
////            return cell
////        }
//        return cell
//    }

//    func setRow_1(UITableViewCell: cell)  {
//        let label = UILabel(frame: CGRectMake())
//        cell
//        return cell
//    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    class MyCell: UITableViewCell{
        var firstRun = UILabel()
        var numRuns = UILabel()
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            firstRun.center = center
            firstRun.text = "First Run"
            addSubview(firstRun)
            addSubview(numRuns)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            firstRun.center = center
            firstRun.text = "First Run"
        }


        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

}

extension UIColor {
    
    convenience init(var hex: String) {
        var alpha: Float = 100
        let hexLength = hex.characters.count
        if !(hexLength == 7 || hexLength == 9) {
            // A hex must be either 7 or 9 characters (#GGRRBBAA)
            print("improper call to 'colorFromHex', hex length must be 7 or 9 chars (#GGRRBBAA)")
            self.init(white: 0, alpha: 1)
            return
        }
        
        if hexLength == 9 {
            // Note: this uses String subscripts as given below
            alpha = hex[7...8].floatValue
            hex = hex[0...6]
        }
        
        // Establishing the rgb color
        var rgb: UInt32 = 0
        let s: NSScanner = NSScanner(string: hex)
        // Setting the scan location to ignore the leading `#`
        s.scanLocation = 1
        // Scanning the int into the rgb colors
        s.scanHexInt(&rgb)
        
        // Creating the UIColor from hex int
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(alpha / 100)
        )
    }
}

extension String {
    
    /**
     Returns the float value of a string
     */
    var floatValue: Float {
        return (self as NSString).floatValue
    }
    
    /**
     Subscript to allow for quick String substrings ["Hello"][0...1] = "He"
     */
    subscript (r: Range<Int>) -> String {
        get {
            let start = self.startIndex.advancedBy(r.startIndex)
            let end = self.startIndex.advancedBy(r.endIndex - 1)
            return self.substringWithRange(start..<end)
        }
    }
}
