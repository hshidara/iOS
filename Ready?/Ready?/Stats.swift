//
//  File.swift
//  Ready?
//
//  Created by Hidekazu Shidara on 11/7/15.
//  Copyright © 2015 Hidekazu Shidara. All rights reserved.
//

import Foundation
import CoreData

@objc(Stats)
class Stats: NSManagedObject {
    @NSManaged var firstRun: NSDate
    @NSManaged var numRuns: Int
    @NSManaged var totalCalories: Double
    @NSManaged var totalMiles: Double
    @NSManaged var totalTime: Double
    @NSManaged var totalTimeHours: Int
    @NSManaged var totalTimeMinutes: Int
    @NSManaged var totalTimeSeconds: Int


}