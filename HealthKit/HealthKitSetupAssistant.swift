//
//  HealthKitSetupAssistant.swift
//  Agon
//
//  Created by Gabriela Villalobos on 20.11.18.
//  Copyright © 2018 UNIL. All rights reserved.
//

import Foundation
import HealthKit


class HealthKitSetupAssistant {
    
    
    
    

class func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void) {

         enum HealthkitSetupError: Error {
            case notAvailableOnDevice
            case dataTypeNotAvailable
        }
    
        //1. Check to see if HealthKit is available on this device
        // Guard statement stops the app from executing the rest of the method's logic if HealthKit is not available on the device
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, HealthkitSetupError.notAvailableOnDevice)
            return
        }
    
        //2. Prepare the data types that will interact with HealthKit
        guard  let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount),
            let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
            let bloodType = HKObjectType.characteristicType(forIdentifier: .bloodType),
            let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex),
            let bodyMassIndex = HKObjectType.quantityType(forIdentifier: .bodyMassIndex),
            let height = HKObjectType.quantityType(forIdentifier: .height),
            let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass),
            let activeEnergy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
                
                completion(false, HealthkitSetupError.dataTypeNotAvailable)
                return
            }
        
    
        //3. Prepare a list of types you want HealthKit to read and write
        let healthKitTypesToWrite: Set<HKSampleType> = [bodyMassIndex,
                                                        activeEnergy,
                                                        HKObjectType.workoutType()]
    
        let healthKitTypesToRead: Set<HKObjectType> = [stepCount,activeEnergy]
    
    
        //4. Request Authorization
    HKHealthStore().requestAuthorization(toShare: nil, read: healthKitTypesToRead) { (success, error) in
                                                completion(success, error)
        }

    }
    
    
//  The authorization status for an HKObjectType does not reflect whether your application has authorization to read samples of those types. It only indicates whether you have requested authorization at all and whether your app is authorized to write samples of those types. So if your app requests authorization to read step count samples but not write them, and the user grants read authorization, then the authorization status for HKQuantityTypeIdentifierStepCount will be HKAuthorizationStatusSharingDenied.
    
    /// Checks if the user granted permission to access the steps from HealthKit FALSE
    class func checkHealthKitAuthorization() -> Bool{
        if (HKHealthStore().authorizationStatus(for: HKObjectType.quantityType(forIdentifier: .stepCount)!) == .sharingDenied){
            print("Success requesting access to steps")
            return true
        } else {
            print("Failed requesting access to steps")
            return false
        }
    }
    
    

    
    class func getHeartRateData()
    {
        let health = HKHealthStore()
        let heartRateType:HKQuantityType   = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        var shownWarning : Bool = false
        let stepCount =  HKObjectType.quantityType(forIdentifier: .stepCount)!
        let startDate = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        let endDate = Date()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        let sortDescriptors = [
            NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)
        ]
        
        let heartRateQuery = HKSampleQuery(sampleType: stepCount,
                                           predicate: predicate,
                                           limit: HKObjectQueryNoLimit,
                                           sortDescriptors: sortDescriptors)
        { (query:HKSampleQuery, results:[HKSample]?, error:Error?) -> Void in
            guard let results = results else { return }
            if results.count == 0 && !shownWarning {
                shownWarning = true
                print("Show warning!")
//                DispatchQueue.main.async {
//                    CheckLoginViewController().showNilError()
//                    //self.showNilError()
//                }
            }
        }
        health.execute(heartRateQuery)
    }
    
}
