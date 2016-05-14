//
//  ConversionToString.swift
//  Ready?
//
//  Created by Hidekazu Shidara on 11/7/15.
//  Copyright © 2015 Hidekazu Shidara. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation
import MapKit
import UIKit
import HealthKit

class conversionToString{
    var time = Time()
    func instantSpeedToString(mph: CLLocationSpeed) -> String{
        if (mph !=  Double.infinity) {
            let intOfMPH = Int(mph)
            let percent = mph - Double(intOfMPH)
    
            let minutes = percent*60
    
    //            let better = String(format: "%.2f", mph)
    //            let better = String(format: "%.2f", intOfMPH)
    
            let betterMinutes = String(format:  "%.00f", minutes)
            if (minutes < 0) && (intOfMPH < 0){
                return "0:00"
            }
            else{
                return "\(intOfMPH):\(betterMinutes)"
            }
        }
        return "0:00"
    }
    
    func distanceToString(distance: Double) -> String{
        let metersToMiles = distance/1609.0
        let betterMiles = String(format: "%.2f", metersToMiles)
        return "\(betterMiles) Miles"
    }
    
    func paceToString(seconds: Double, distance: Double) -> String{
        let paceUnit = HKUnit.secondUnit().unitDividedByUnit(HKUnit.meterUnit())
        _ = HKQuantity(unit: paceUnit, doubleValue: seconds / distance)
        
        let milesPerHour = (seconds/distance) * (1609/60)
        
        if (milesPerHour !=  Double.infinity) {
            let intOfMPH = Int(milesPerHour)
            let percent = milesPerHour - Double(intOfMPH)
            
            let minutes = percent*60
            
            _ = String(format: "%.2f", milesPerHour)
            
            let betterMinutes = String(format:  "%.0f", minutes)
//            paceLabel.text = "\(intOfMPH):\(betterMinutes)"
            return  "\(intOfMPH):\(betterMinutes)"
        }
        return "Not Available"
    }
    
    func timeToString(startTime: NSTimeInterval) -> String {
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        
        //Find the difference between current time and start time.
        
        var elapsedTime: NSTimeInterval = currentTime - startTime
        
        //calculate the minutes in elapsed time.
        
        let minutes = UInt8(elapsedTime / 60.0)
        time.minutes = minutes
        elapsedTime -= (NSTimeInterval(minutes) * 60)
        //calculate the seconds in elapsed time.
        
        let seconds = UInt8(elapsedTime)
        time.seconds = seconds
        elapsedTime -= NSTimeInterval(seconds)
        
        let hours = UInt8(elapsedTime)
        time.hours = hours
        let strHours = String(format: "%02d", hours)
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        
        return "\(strHours):\(strMinutes):\(strSeconds)"
    }
    
    func brokenTimeToString(seconds: Int, minutes: Int, hours: Int) -> String{

        let strHours = String(format: "%02d", hours)
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        
        return "\(strHours):\(strMinutes):\(strSeconds)"

    }
    
    func altitudeToString(altitude: Double) -> String{
        let better = String(format: "%.1f", altitude)
        return better
    }
    
    func getTime() -> Time{
        return self.time
    }
    
    func addTime(time:Time, seconds: Int, minutes: Int, hours: Int) -> Time{
        var mins = 0
        var lol = 0
        var secs = Int(time.seconds!) + seconds
        if secs > 59{
            mins++
            secs = secs - 60
        }
        mins = Int(time.minutes!) + minutes
        if mins > 59{
            lol++
            mins = mins - 60
            
        }
        lol = Int(time.hours!) + hours

        time.seconds = UInt8(secs)
        time.minutes = UInt8(mins)
        time.hours = UInt8(lol)

        return time
    }
}

class Time {
    var seconds: UInt8?
    var minutes: UInt8?
    var hours: UInt8?
    
    init(){
        seconds = 0
        minutes = 0
        hours = 0
    }
    
    
//    static func getTime
}