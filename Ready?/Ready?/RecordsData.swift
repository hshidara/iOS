//
//  RecordsData.swift
//  Ready?
//
//  Created by Hidekazu Shidara on 11/8/15.
//  Copyright © 2015 Hidekazu Shidara. All rights reserved.
//

import Foundation
import CoreData

@objc(RecordsData)
class RecordsData: NSManagedObject {
    @NSManaged var highestAltitude: Double
    @NSManaged var longestRun: Double
    @NSManaged var mostCaloriesInARun: Double
    @NSManaged var mostStepsTakenAtOnce: Int64
}