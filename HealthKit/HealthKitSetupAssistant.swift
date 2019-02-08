//
//  HealthKitSetupAssistant.swift
//  Agon
//
//  Created by Gabriela Villalobos on 20.11.18.
//  Copyright © 2018 UNIL. All rights reserved.
//

import Foundation
import HealthKit

typealias AccessRequestCallback = (_ success: Bool, _ error: Error) -> Void


protocol HealthKitSetupAssistantProtocol: class {
    func updateStepsNumberLabel(steps : Double)
}

class HealthKitSetupAssistant {

    // Properties
    private let healthStore = HKHealthStore()
    var internetConnection = false
    weak var delegate : HealthKitSetupAssistantProtocol?
    let dashboardController = DashboardController()
    
    
    /// Requests access to all the data types the app wishes to read/write from HealthKit.
    /// On success, data is queried immediately and observer queries are set up for background
    /// delivery. This is safe to call repeateddly and should be called at least once per launch.
    
    func requestAccessWithCompletion(completion: @escaping AccessRequestCallback){
        guard deviceSupportsHealthKit() else{
            debugPrint("Can't request access to HealthKit when it's not suporte on the device.")
            return
        }
        
        let readDataTypes = dataTypesToRead()
        
        healthStore.requestAuthorization(toShare: nil, read: readDataTypes) {[weak self] (success: Bool, error: Error?) in
            guard let strongSelf = self else { return }
            if success{
                debugPrint("Access to HealthKit data has been granted from SetupAssistant")
                //strongSelf.readHealthKitData()
//                strongSelf.getTodayStepCount(completion: { (steps) in
//                    print("Steps outside backgroun delivery \(steps)")
//                })
                strongSelf.setUpBackgroundDeliveryForDataTypes(types: readDataTypes, completion: { steps in
                    ///  review how to send data from here to the dashboard view controller
                    print("Steps from background: \(steps)")
                    strongSelf.delegate?.updateStepsNumberLabel(steps: steps)
                    strongSelf.dashboardController.storeStepsInWebServer(steps: steps)
                    strongSelf.dashboardController.updateStepsLabel(steps: steps)
                    //strongSelf.delegate.userStepsRetrieved(steps: steps)
                })
            }
            else{
                //debugPrint("Error requesting HealthKit authorization: \(error ?? default "Default Error Message"))")
                debugPrint("Error requesting HealthKit authorization: \(error)")
                print("Error requesting HealthKit authorization")
            }
            
            DispatchQueue.main.async {
                guard error != nil else{
                    return
                }
                completion(success, error!)
                
            }
        }
    }
    
    func deviceSupportsHealthKit() -> Bool {
        //1. Check to see if HealthKit is available on this device
        // Guard statement stops the app from executing the rest of the method's logic if HealthKit is not available on the device
        return HKHealthStore.isHealthDataAvailable()
    }
    



/// Function to request access to healthkit data -- I am not using this one right now
///
/// - Parameter completion: authorization requested successfully
func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void) {

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
        guard  let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount) else {
                
                completion(false, HealthkitSetupError.dataTypeNotAvailable)
                return
            }
        
    
        //3. Prepare a list of types you want HealthKit to read
        let healthKitTypesToRead: Set<HKObjectType> = [stepCount]
    
    
        //4. Request Authorization
//    HKHealthStore().requestAuthorization(toShare: nil, read: healthKitTypesToRead) { (success, error) in
//                                                completion(success, error)

    HKHealthStore().requestAuthorization(toShare: nil, read: healthKitTypesToRead) { (success: Bool, error: Error?) in
        
        if success {
            debugPrint("Access to HealthKit data has been granted")
            //strongSelf.readHealthKitData()
            
            //self.setUpBackgroundDeliveryForDataTypes(types: healthKitTypesToRead)
            
        } else {
            debugPrint("Error requesting HealthKit authorization: \(String(describing: error))")
        }
        
        DispatchQueue.main.async {
            completion(success, error)
        }
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
    

}


// Mark: - Private
extension HealthKitSetupAssistant{
    /// Initiates an `HKAnchoredObjectQuery` for each type of data that the app reads and stores
    /// the result as well as the new anchor.
    func readHealthKitData() { /* ... */ }
    
    /// Sets up the observer queries for background health data delivery.
    ///
    /// - parameter types: Set of `HKObjectType` to observe changes to.
    func setUpBackgroundDeliveryForDataTypes(types: Set<HKObjectType>, completion: @escaping (Double) -> Void){
        for type in types{
            guard let sampleType = type as? HKSampleType else {print ("ERROR: \(type) is not an HKSampleType"); continue}
            
            let query = HKObserverQuery(sampleType: sampleType, predicate: nil) {
                [weak self] HKObserverQuery, completionHandler, error in
                
                if error != nil{
                    print("*** An error occured. \(error!.localizedDescription) ***")
                    debugPrint("observer query update handler called for type \(type), error: \(String(describing: error))")
                    return
                }
                
                guard let strongSelf = self else {return}
            
                strongSelf.getTodayStepCount(completion: {steps in
                    completion(steps)
                })
                
                //HKObserverQueryCompletionHandler() // not so sure which completion handler to use
                completionHandler()
            }
            
            healthStore.execute(query)
            healthStore.enableBackgroundDelivery(for: type, frequency: .immediate, withCompletion: ({ (success: Bool, error: Error?) in
                if success{
                    print("\(type) registered for background delivery")
                }
                else{
                    print("\(type) NOT registered for background delivery")
                    debugPrint("enableBackgroundDeliveryForType handler called for \(type) - success: , error: \(String(describing: error))")
                }
                
            }))
            
        }
    }
    
    func observerCompletionHandler(value : Double){
        print ("observer Completion Handler value : \(value)")
    }
    
    /// Initiates HK queries for new data based on the given type
    ///
    /// - parameter type: `HKObjectType` which has new data avilable.
    func queryForUpdates(type: HKObjectType) {
        switch type {
        case HKObjectType.quantityType(forIdentifier: .stepCount):
            debugPrint("HKQuantityTypeIdentifierStepCount")
            
        default: debugPrint("Unhandled HKObjectType: \(type)")
        }
    }
    
    /// Types of data that this app wishes to read from HealthKit.
    ///
    /// - returns: A set of HKObjectType.
    func dataTypesToRead() -> Set<HKObjectType> {
        return Set(arrayLiteral:
            HKObjectType.quantityType(forIdentifier: .stepCount)!
        )
    }
    
    func getStepsOnDate(completion:@escaping (Double) -> Void) {
        let startOfDay = getSpecificDate(year: 2018, month: 12, day: 7, hour: 0, minute: 0, second: 0)
        let endOfDay = getSpecificDate(year: 2018, month: 12, day: 7, hour: 23, minute: 59, second: 59)
        
        requestStepsToHKWithCompletion(start: startOfDay, end: endOfDay, completion: {steps in
            print(steps)
            completion(steps)
        })
        
//        startOfDay = getSpecificDate(year: 2018, month: 12, day: 6, hour: 0, minute: 0, second: 0)
//        endOfDay = getSpecificDate(year: 2018, month: 12, day: 6, hour: 23, minute: 59, second: 59)
//        requestStepsToHKWithCompletion(start: startOfDay, end: endOfDay, completion: {steps in
//            print(steps)
//        })
    }
    
    func getTodayStepCount(completion: @escaping (Double) -> Void){
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        
        requestStepsToHKWithCompletion(start: startOfDay, end: now, completion: {steps in
            print("-----------> Today step count: \(steps)")
            completion(steps)
        })
    
    }
    
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

}


extension HealthKitSetupAssistant{
    
    func requestStepsToHKWithCompletion(start : Date , end : Date, completion:@escaping (Double) -> Void){
        
        let timePredicate : NSPredicate = HKQuery.predicateForSamples(withStart: start as Date, end: end as Date, options: .strictStartDate)
        // Get only steps which were NOT user entered. HKMetadataKeyWasUserEntered == true
        let notManuallyInputPredicate: NSPredicate = HKQuery.predicateForObjects(withMetadataKey: HKMetadataKeyWasUserEntered, operatorType: .notEqualTo, value: true)
        // Builds a compound predicate with time and notManually input steps
        let predicate: NSCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [timePredicate, notManuallyInputPredicate])
        
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
        let query = HKStatisticsQuery(quantityType: stepsQuantityType,
                                      quantitySamplePredicate: predicate,
                                      options: .cumulativeSum) { (_, result, error) in
                                        var resultCount = 0.0
                                        
                                        guard let result = result else{
                                            print ("Failed to fetch steps = \(error?.localizedDescription ?? "N/A")")
                                            completion(resultCount)
                                            return
                                        }
                                        
                                        if let sum = result.sumQuantity() {
                                            resultCount = sum.doubleValue(for: HKUnit.count())
                                            print ("Start: ", start)
                                            print ("End: ", end)
                                            print ("Steps: ", resultCount)
                                            //self.stepsNumber = resultCount
                                        }
                                        
                                        DispatchQueue.main.async {
                                            completion(resultCount)
                                        }
        }
        healthStore.execute(query)
    }
    
    func getNStepsBack(daysBack : Int){
        for i in 0 ..< daysBack{
            
            let yesterdayStartOfDay = getNDaysBackStartOfDay(numberOfDaysBack: i)
            let yesterdayEndOfDay = getNDaysBackEndOfDay(numberOfDaysBack: i)
            
            requestStepsToHKWithCompletion(start: yesterdayStartOfDay, end: yesterdayEndOfDay, completion: {steps in
                print("YESTERDAY START: ", yesterdayStartOfDay)
                print("YESTERDAY END: ", yesterdayEndOfDay)
                self.internetConnection = Reachability().isInternetAvailable()
                if(self.internetConnection){
//                    self.submitSteps(steps: steps,
//                                     userId: self.getUserId(),
//                                     timestamp: self.convertDateToString(date: yesterdayEndOfDay),
//                                     completion: {result in
//                                        print(result)
//
//                                        if(result == "done"){
//                                            self.createStepObject(userId: self.getUserId(), steps: steps, timestamp: self.convertDateToString(date: yesterdayEndOfDay))
//                                            self.insertNewSyncDate()
//                                        }
//                                        else if(result == "Code=-1001"){ // The request timed out.
//                                            self.createFailedStepObject(userId: self.getUserId(),
//                                                                        steps: steps,
//                                                                        timestamp: self.convertDateToString(date: yesterdayEndOfDay))
//                                        }
//                    })
                }
                else{
                    //self.storeStepsOnDisk(steps: steps, timestamp: self.convertDateToString(date: yesterdayEndOfDay))
//                    self.createStepObject(userId: self.getUserId(), steps: steps, timestamp: self.convertDateToString(date: yesterdayEndOfDay))
                }
            })
        }
    }
    
    // Always use UTC time for calculations. Do not add two hours to UTC!
    private func getNDaysBackStartOfDay(numberOfDaysBack : Int)->Date{
        var calendar = Calendar.current
        //calendar.timeZone = TimeZone(abbreviation: "UTC")! //OR NSTimeZone.localTimeZone()
        calendar.timeZone = NSTimeZone.local
        let dateAtMidnight = calendar.startOfDay(for: Date())
        
        let components = NSDateComponents()
        components.day = -numberOfDaysBack - 1
        
        let yesterDayStartofDay = calendar.date(byAdding: components as DateComponents, to: dateAtMidnight)
        
        return yesterDayStartofDay!
        
    }
    
    private func getNDaysBackEndOfDay(numberOfDaysBack : Int)->Date{
        var calendar = Calendar.current
        //calendar.timeZone = TimeZone(abbreviation: "UTC")! //OR NSTimeZone.localTimeZone()
        calendar.timeZone = NSTimeZone.local
        let dateAtMidnight = calendar.startOfDay(for: Date())
        
        
        let components = NSDateComponents()
        components.day = -numberOfDaysBack //tenía 0
        components.second = -1
        
        let yesterDayStartofDay = calendar.date(byAdding: components as DateComponents, to: dateAtMidnight)
        
        return yesterDayStartofDay!
        
    }
    
    
    /// Calculates the average daily step counts based
    /// on the previous week.
    ///
    /// - Parameter completion: resturns the average daily step count when finishes the calculation
    func getDailyAverageStepCount(completion:@escaping (Double) -> Void){
        
        /// get the step counts from last week
        let daysToSubstract = -6
        let currentDate = Date()
        let cal = Calendar(identifier: .gregorian)
        let currentDateAtMidnight = cal.startOfDay(for: currentDate)
        
        var dateComponent = DateComponents()
        
        dateComponent.day = daysToSubstract
        
        let oneWeekAgoDate = Calendar.current.date(byAdding: dateComponent, to: currentDateAtMidnight)
        
        requestStepsToHKWithCompletion(start: oneWeekAgoDate!, end: Date()) { (steps) in
            let averageDailySteps = steps / 7
            print("Average Daily Steps: \(averageDailySteps)")
            completion(averageDailySteps)
        } 
    }
    
    
    
}
