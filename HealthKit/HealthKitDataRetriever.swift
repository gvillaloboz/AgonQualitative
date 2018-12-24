//
//  HealthKitDataRetriever.swift
//  Agon
//
//  Created by Gabriela Villalobos on 22.11.18.
//  Copyright © 2018 UNIL. All rights reserved.
//

import Foundation
import HealthKit

protocol HealthKitDataRetrieverProtocol: class {
    func stepCountsDownloaded(data : String)
}

class HealthKitDataRetriever {

    // Properties
    
    let healthStore = HKHealthStore()
    
    // Functions
    
    func retrieveStepCountsFromHKStore(){
        
//        let sampleType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
//
//        let query =   (sampleType: sampleType,
//                                    predicate: nil,
//                                    updateHandler)
//        { (query: query, completionHandler: completionHandler, error: Error?) -> Void in
//
//            if error != nil {
//                // Perform Proper Error Handling Here...
//                println("*** An error occured while setting up the stepCount observer. \(error.localizedDescription) ***")
//                abort()
//            }
//
//            // Take whatever steps are necessary to update your app's data and UI
//            // This may involve executing other queries
//            //self.updateDailyStepCount()
//
//            // If you have subscribed for background updates you must call the completion handler here.
//            // completionHandler()
//        }
//
//        healthStore.execute(query)
//        
//        DispatchQueue.main.async(execute: { () -> Void  in
//
//            //self.delegate.stepCountsDownloaded(data: "")
//        })
        
    }
    
    func updateHandler(){
        
    }
    
    func completionHandler(){
        
    }
    
    
}
