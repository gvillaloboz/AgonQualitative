//
//  SynchronizationModel.swift
//  Agon
//
//  Created by Gabriela Villalobos-Zúñiga on 29.01.19.
//  Copyright © 2019 UNIL. All rights reserved.
//

import Foundation
import RealmSwift

final class SynchronizationModel: Object{
    
    // MARK: - Properties
    @objc dynamic var lastSyncTimestamp = Date()
    @objc dynamic var lastSyncSteps = 0.0
    
    func getLastSyncTimestamp() -> Date{
        let realm = try! Realm()
        if (realm.objects(SynchronizationModel.self).isEmpty){
            return getSpecificDate(year: 1999, month: 1, day: 1, hour: 0, minute: 0, second: 0)
        }
        else{
            let lastSyncTimestamp = realm.objects(SynchronizationModel.self).last?.lastSyncTimestamp
            print("Last Sync Timestamp: ", lastSyncTimestamp!)
            return lastSyncTimestamp!
        }
    }
    
    
    
    
    func getLastSyncSteps() -> Double{
        let realm = try! Realm()
        if (realm.objects(SynchronizationModel.self).isEmpty){
            return 0.0
        }
        else{
            let lastSyncSteps = realm.objects(SynchronizationModel.self).last?.lastSyncSteps
            print("Last Sync Steps: ", lastSyncSteps!)
            return lastSyncSteps!
        }
    }
    
    
    
    
    // MARK: - Functions
    func getSpecificDate(year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int) -> Date{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        dateFormatter.locale = Locale.init(identifier: "en_GB")
        dateFormatter.timeZone = NSTimeZone.local //just added 22.08.17
        
        let dateComponents:NSDateComponents = NSDateComponents()
        dateComponents.timeZone = NSTimeZone.local //just added 22.08.17
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hour // Because Date() return GMT * check *
        dateComponents.minute = minute
        dateComponents.second = second
        
        let calendar:NSCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let date:NSDate = calendar.date(from: dateComponents as DateComponents)! as NSDate
        return date as Date
        
    }
    
    func initializeLastDaySync(year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int)-> Void{
        
        let storedLastDaySync = getLastSyncTimestamp() // if there is anything stored
        
        let lastDaySync = getSpecificDate(year: year, month: month, day: day, hour: hour, minute: minute, second: second)
        
        //let difference  = lastDaySync < storedLastDaySync
        let difference = getDifferenceInDays(start: storedLastDaySync, end: lastDaySync)
        
        if(difference > 0){
            let synchronizationModel = SynchronizationModel()
            synchronizationModel.lastSyncTimestamp = lastDaySync
            
            let realm = try! Realm()
            
            try! realm.write{
                realm.add(synchronizationModel)
            }
        }
    }
    
    func getDifferenceInDays(start : Date, end : Date) -> Int{
        
        //let startLocalString = UTCToLocal(date: start)
        //let endLocalString = UTCToLocal(date: end)
        
        let startLocalString = getJustDate(date: start)
        let endLocalString = getJustDate(date: end)
        
        print(start)
        print(end)
        let components = Calendar.current.dateComponents([.day], from: start, to: end)
        print(startLocalString)
        print(endLocalString)
        let components2 = Calendar.current.dateComponents([.day], from: startLocalString, to: endLocalString)

        print("difference is \(components.day ?? 0) days")
        
        print("difference is \(components2.day ?? 0) days")
        
        return components2.day ?? 0
    }
    
    func getJustDate(date: Date)->Date{
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date
        formatter.dateFormat = "yyyy-MM-dd H:mm:ss a"
        //formatter.timeZone = TimeZone(identifier: "UTC")!
        formatter.timeZone = NSTimeZone.local
        let myString = formatter.string(from: date)
        // convert your string to date
        let yourDate = formatter.date(from: myString)
        formatter.locale = Locale(identifier: "en_US_POSIX") //ARG
        //then again set the date format whhich type of output you need
        formatter.dateFormat = "yyyy-MM-dd"
        // again convert your date to string
        let myStringafd = formatter.string(from: yourDate!)
        
        let dt = formatter.date(from: myStringafd)
        
        return dt!
        
    }
    
    func updateLastSyncTimestampAndSteps(steps : Double){
        let synchronizationModel = SynchronizationModel()
        synchronizationModel.lastSyncTimestamp = Date()
        synchronizationModel.lastSyncSteps = steps
        
        let realm = try! Realm()
        
        try! realm.write{
            realm.add(synchronizationModel)
        }
    }
    
    
    
}
