//
//  MainScreenViewController.swift
//  Agon
//
//  Created by Gabriela Villalobos on 22.11.18.
//  Copyright © 2018 UNIL. All rights reserved.
//
//  Image credits: competition by pictohaven from the Noun Project


import Foundation
import UIKit
import HealthKit
import RealmSwift

protocol shareHealthDataDelegate : class {
    func downloadWeeklyGoal(weeklyStepsGoal : Double)
}

class MainScreenViewController : UIViewController  { //HealthKitDataRetrieverProtocol
    
    /// MARK: - Properties
    
    @IBOutlet weak var instructionsTextField: UITextView!
    @IBOutlet weak var acceptGoalButton: UIButton!
    @IBOutlet weak var denyGoalButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
        
    private let healthkitSetupAssistant = HealthKitSetupAssistant()
    private let trialController = TrialController()
    private let dashboardController = DashboardController()
    var synchronizationModel = SynchronizationModel()
    
    var trialStatus = Int()
    var weeklyGoal = Double()
    var averageDailySteps = Double()
    var endTimeStamp = Date()
    var averageDailyStepsFlag = false
    var denyGoalFlag = false
    var internetConnection = false
    
    weak var delegate : shareHealthDataDelegate?
    private let healthStore = HKHealthStore()
    
    
    /// MARK: - Functions
    
    override func viewDidLoad() {
        hideUIComponents()
        styleTextView()
        styleButtons()
    }
    
    
    override func viewDidAppear(_ animated: Bool){

        // Health Kit Code to retrieve baseline steps
        if HKHealthStore.isHealthDataAvailable() {
            let readDataTypes = self.stepsTypesToRead()
            
            self.healthStore.requestAuthorization(toShare: [], read: readDataTypes, completion: { [unowned self] (success, error) in
                if success {
                    DispatchQueue.main.async {
                        //self.updateUsersStepsLabelAndDateValueLabel()
                        self.pushUnsyncStepsToServer()
                    }
                    
                } else if let error = error {
                    print(error.localizedDescription)
                }
            })
            
        }

        // A competition is a week of recording step data. During a competition each participant has a weekly step goal.
        //  get the competition status from Realm
        // think of how to turn this competition status to 0 by the end of the week
        self.trialStatus = trialController.getTrialStatus()
        
        switch self.trialStatus {
        
        case 0: // no running trial
            print("No running competition")
            // fork should occur after setting the instructions for the weekly goal
            displayOptimalChallengeInstructions()
        
        case 1: // running trial
            print("Running competition")
            denyGoalButton.isHidden = true
            acceptGoalButton.isHidden = true
            performSegue(withIdentifier: "mainToDashboardSegue", sender: self)
            
        default:
            print("No valid competition status")
        }
    }
    
    private func stepsTypesToRead() -> Set<HKObjectType> {
        let stepsType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
        
        return [stepsType]
    }
    
    
    /// <#Description#>
    ///
    /// - Parameter data: <#data description#>
    func stepCountsDownloaded(data: String) {
        print("Call to steps data downloaded")
    }
    
    
    /// Displays on streen the instructions for the optimal challenge
    /// This action will give as a result the weekly step goal
    func displayOptimalChallengeInstructions(){
        /// Requests average steps
        healthkitSetupAssistant.getDailyAverageStepCount(completion: {averageSteps in
        self.averageDailySteps = averageSteps.truncate(places: 0)
            
        // check if average daily steps is at least
        if(self.averageDailySteps < 1000){
            self.averageDailySteps = 5000
            self.averageDailyStepsFlag = true
        }
            
        if(!self.averageDailyStepsFlag){
            self.instructionsTextField.text = "Tu promedio diario de pasos es \(Int(self.averageDailySteps)). \n ¿Te gustaría incrementarlo en un 5%? \n Eso es caminar \((Int(self.averageDailySteps * 0.05))) pasos adicionales o alrededor de \((self.averageDailySteps *  0.05 * 0.013).truncate(places: 2)) minutos caminando."
            
            self.acceptGoalButton.isHidden = false
            self.denyGoalButton.isHidden = false
        }else{
            self.instructionsTextField.text = "No tenemos datos suficientes para calcular tu promedio diario de pasos. Por eso te sugerimos \(Int(self.averageDailySteps))."
            
            self.acceptGoalButton.isHidden = true
            self.denyGoalButton.isHidden = true
            self.okButton.isHidden = false
            
            //self.trialStatus = 1
        }
            self.instructionsTextField.isHidden = false
            
            })
    }

    
    
    
    
    
    /// Action for the accept button
    /// Calculates the weekly goal based on the average daily steps and
    /// displays it on the screen. Shows the OK button.
    ///
    /// - Parameter sender: accept button
    @IBAction func acceptGoalButtonAction(_ sender: Any) {
        var weeklyGoal : Double
        if(!self.averageDailyStepsFlag){
            weeklyGoal = (self.averageDailySteps * 7) + ((self.averageDailySteps * 0.05) * 7)
        }
        else{
            weeklyGoal = (self.averageDailySteps * 7)
        }
        instructionsTextField.text = "Tu objetivo esta semana será de alcanzar \(Int(weeklyGoal)) pasos. \n\n Esto es aproximadamente \(Int(weeklyGoal / 7)) pasos en un día."
        
        self.weeklyGoal = weeklyGoal
        //self.trialStatus = 1
        self.endTimeStamp = Date.today().next(.monday)
        print(Date.today().next(.monday))
        
        
        acceptGoalButton.isHidden = true
        denyGoalButton.isHidden = true
        okButton.isHidden = false
    }
     
    
    @IBAction func denyGoalButtonAction(_ sender: Any) {
        instructionsTextField.text = "¡No hay problema! Tratá de mantener tu promedio diario de pasos como tu objetivo para esta semana, eso es \(self.averageDailySteps.truncate(places: 0)) pasos."
        
        self.weeklyGoal = self.averageDailySteps
        self.trialStatus = 1
        
        denyGoalButton.isHidden = true
        acceptGoalButton.isHidden = true
        okButton.isHidden = false
        
        self.denyGoalFlag = true
    }
    
    
    /// Saves the trial status and the weekly goal in the local realm
    /// Hides the ok button and segues to the Dashboard View Controller
    ///
    /// - Parameter sender: OK button
    @IBAction func okButtonAction(_ sender: Any) { ///add timestamp to competition status
        var weeklyGoal : Double
        if(!self.averageDailyStepsFlag && !self.denyGoalFlag){
            weeklyGoal = (self.averageDailySteps * 7) + ((self.averageDailySteps * 0.05) * 7)
        }
        else{
            weeklyGoal = (self.averageDailySteps * 7)
        }
        self.weeklyGoal = weeklyGoal
        self.trialStatus = 1
        self.endTimeStamp = Date.today().next(.monday)
        
        //Save trial status (goal) in the realm
        trialController.storeTrialObjectLocally(weeklyGoal: self.weeklyGoal, status : self.trialStatus, endTimeStamp: self.endTimeStamp,  completion: { success in
            print("Competition Status succesfully inserted in local realm")
            print("Weekly Goal: \(self.weeklyGoal)")
            print("Trial Status: \(self.trialStatus)")
        })
        
        // Hide ok Button
        okButton.isHidden = true
        
        // Send weekly steps goal to DashboardViewController -> this might not be needed because I am storing the weekly goal on the local realm
        //delegate?.downloadWeeklyGoal(weeklyStepsGoal: self.weeklyGoal)
        
        performSegue(withIdentifier: "mainToDashboardSegue", sender: self)
    
    }
    
    
    /// Hides the UI components for buttons
    /// and instructions text field
    func hideUIComponents(){
        okButton.isHidden = true
        acceptGoalButton.isHidden = true
        denyGoalButton.isHidden = true
        instructionsTextField.isHidden = true
    }
    
    func styleTextView(){
        instructionsTextField.layer.backgroundColor = Color().getPurple()
        instructionsTextField.layer.cornerRadius = 5
        instructionsTextField.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        instructionsTextField.layer.borderWidth = 0.5
        instructionsTextField.clipsToBounds = true

    }
    
    func styleButtons(){
        acceptGoalButton.layer.cornerRadius = 5
        acceptGoalButton.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        acceptGoalButton.layer.borderWidth = 0.5
        acceptGoalButton.layer.backgroundColor = Color().getOrange()
        acceptGoalButton.setTitleColor(.white, for: .normal)
        
        denyGoalButton.layer.cornerRadius = 5
        denyGoalButton.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        denyGoalButton.layer.borderWidth = 0.5
        denyGoalButton.layer.backgroundColor = Color().getOrange()
        denyGoalButton.setTitleColor(.white, for: .normal)
        
        okButton.layer.cornerRadius = 5
        okButton.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        okButton.layer.borderWidth = 0.5
        okButton.layer.backgroundColor = Color().getOrange()
        okButton.setTitleColor(.white, for: .normal)
        
    }
    
    /// BEGINS CODE FROM POW THAT EXTRACTS THE BASELINE FOR NUMBER OF STEPS
    
    //MARK: Push Unsync Steps to Server
    
    private func pushUnsyncStepsToServer(){
        let lastDaySync = synchronizationModel.getLastSyncTimestamp()
        let unsyncDays = getDifferenceInDays(start: lastDaySync, end: Date())
        getNStepsBack(daysBack: unsyncDays)
    }
    
    
    private func getNStepsBack(daysBack : Int){
        for i in 0 ..< daysBack{
            
            let yesterdayStartOfDay = getNDaysBackStartOfDay(numberOfDaysBack: i)
            let yesterdayEndOfDay = getNDaysBackEndOfDay(numberOfDaysBack: i)
            
            requestStepsToHKWithCompletion(start: yesterdayStartOfDay, end: yesterdayEndOfDay, completion: {steps in
                print("YESTERDAY START: ", yesterdayStartOfDay)
                print("YESTERDAY END: ", yesterdayEndOfDay)
                self.internetConnection = Reachability().isInternetAvailable()
                if(self.internetConnection){
                    self.submitSteps(steps: steps,
                                     userId: self.getUserId(),
                                     timestamp: self.convertDateToString(date: yesterdayEndOfDay),
                                     completion: {result in
                                        print(result)
                                        
                                        if(result == "done"){
                                            self.createStepObject(userId: self.getUserId(), steps: steps, timestamp: self.convertDateToString(date: yesterdayEndOfDay))
                                            self.insertNewSyncDate()
                                       //this is for the new syncronization model
                                        self.synchronizationModel.updateLastSyncTimestampAndSteps(steps: steps)
                                        }
                                        else if(result == "Code=-1001"){ // The request timed out.
                                            self.createFailedStepObject(userId: self.getUserId(),
                                                                        steps: steps,
                                                                        timestamp: self.convertDateToString(date: yesterdayEndOfDay))
                                        }
                    })
                }
                else{
                    //self.storeStepsOnDisk(steps: steps, timestamp: self.convertDateToString(date: yesterdayEndOfDay))
                    self.createStepObject(userId: self.getUserId(), steps: steps, timestamp: self.convertDateToString(date: yesterdayEndOfDay))
                }
            })
        }
    }
    
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
    
    //MARK: Calculations
    
    private func getDifferenceInDays(start : Date, end : Date) -> Int{
        
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
    
    private func getJustDate(date: Date)->Date{
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
        var myStringafd = formatter.string(from: yourDate!)
        
        var dt = formatter.date(from: myStringafd)
        
        return dt!
        
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
    
    private func requestStepsToHKWithCompletion(start : Date , end : Date, completion:@escaping (Double) -> Void){
        
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
                                            //print ("Start: ", start)
                                            //print ("End: ", end)
                                            //print ("Steps: ", resultCount)
                                            //self.stepsNumber = resultCount
                                        }
                                        
                                        DispatchQueue.main.async {
                                            completion(resultCount)
                                        }
        }
        healthStore.execute(query)
    }
    
    private func convertDateToString(date : Date) -> String{
        var myStringafd : String
        
        let locale = NSLocale.current
        let f : String = DateFormatter.dateFormat(fromTemplate: "j", options:0, locale:locale)!
        if f.contains("a") {
            //phone is set to 12 hours
            print("12hr")
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
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            // again convert your date to string
            myStringafd = formatter.string(from: yourDate!)
            
            
        } else {
            //phone is set to 24 hours
            print("24hr")
            let formatter = DateFormatter()
            // initially set the format based on your datepicker date
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            //formatter.timeZone = TimeZone(identifier: "UTC")!
            formatter.timeZone = NSTimeZone.local
            let myString = formatter.string(from: date)
            // convert your string to date
            let yourDate = formatter.date(from: myString)
            //then again set the date format whhich type of output you need
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            // again convert your date to string
            myStringafd = formatter.string(from: yourDate!)
            
            //print(myStringafd)
        }
        
        return myStringafd
    }
    
    
    /// Inserts into steps table the number of steps given
    ///
    /// - Parameter steps: number of steps retrieved
    func submitSteps(steps: Double, userId: String, timestamp: String, completion:@escaping (String) -> Void){
        let request = NSMutableURLRequest(url: NSURL (string: "https://pow.unil.ch/agon/phpScripts/storeSteps.php")! as URL)
        request.httpMethod = "POST"
        
        // Convert Date to String
        let a = String(describing: timestamp)
        let backSlash = "\'"
        let timeString = backSlash + a + backSlash
        // End Convert Date to String
        
        let postString = "a=\(steps)&b=\(userId)&c=\(timeString)"
        print(postString)
        
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest){
            data, response, error in
            
            if error != nil {
                print("error=\(error!)")
                var splitString = [String]()
                splitString = (String(describing: error).components(separatedBy: " "))
                completion(splitString[2])
                return
            }
            
            //print("response = \(response!)")
            
            let responseString =  String(data: data!, encoding: .utf8)
            
            print("respnseString = \(responseString!)")
            
            var splitString = [String]()
            splitString = (responseString?.components(separatedBy: "."))!
            completion(splitString[0])
        }
        task.resume()
    }
    
    private func pushFailedStepsToServer(){
        let failedStepsArray = getFailedSyncSteps()
        
        for failedStep in failedStepsArray{
            
            let steps = failedStep.steps
            let userId = failedStep.userId
            let timestamp = failedStep.timestamp
            
            if(self.internetConnection){
                self.submitSteps(steps: steps,
                                 userId: userId,
                                 timestamp: timestamp,
                                 completion: {result in
                                    print(result)
                                    
                                    if(result == "done"){
                                        self.createStepObject(userId: userId, steps: steps, timestamp: timestamp)
                                        let realm = try! Realm()
                                        try! realm.write {
                                            realm.delete(realm.objects(FailedStep.self).filter("timestamp=%@",timestamp))
                                        }
                                        
                                        self.insertNewSyncDate()
                                    }
                                    else if(result == "Code=-1001"){ // The request timed out.
                                        self.createFailedStepObject(userId: userId,
                                                                    steps: steps,
                                                                    timestamp: timestamp)
                                    }
                })
            }
        }
    }
    
    private func insertNewSyncDate(){
        let sync = Sync()
        sync.timestamp = getCurrentDate() // Tenía Date()
        //let dateString = self.convertDateToString(date: Date())
        //sync.timestamp = Date()
        print("LAST SYNC: ", sync.timestamp)
        let realm = try! Realm()
        
        try! realm.write{
            realm.add(sync)
        }
        
    }
    
    private func getCurrentDate()->Date{
        // Este código verdaderamente le da el now o tiempo actual,
        var calendar = Calendar.current
        //calendar.timeZone = TimeZone(abbreviation: "UTC")! //OR NSTimeZone.localTimeZone() FIXED 24.08.17
        calendar.timeZone = NSTimeZone.local
        let components = NSDateComponents()
        // Está agregando, sin el day = 0 le agrega un día del componente anterior
        components.day = 0
        components.hour = 0
        components.second = 0
        components.timeZone = NSTimeZone.local
        
        let now = calendar.date(byAdding: components as DateComponents, to: Date())
        //
        return now!
    }
    
    func getFailedSyncSteps()->Results<FailedStep>{
        let realm = try! Realm()
        let failedSyncStepsArray = realm.objects(FailedStep.self)
        return failedSyncStepsArray
    }
    
    //MARK: Realm
    
    /// Stores on disk the step object
    ///
    /// - Parameter email:
    
    func createStepObject(userId: String, steps: Double, timestamp: String)-> Void{
        let step = Step()
        step.userId = userId
        step.steps = steps
        step.timestamp = timestamp
        
        let realm = try! Realm()
        
        try! realm.write{
            realm.add(step)
            //print("[ Step Object Created ] Steps: ", steps, "User Id: ", userId, "Timestamp: ", timestamp)
        }
    }
    
    func getUserId() -> String{
        let realm = try! Realm()
        let userId = realm.objects(RealmUserModel.self).first?.id // Check as I am getting the first one
        
        return userId!
    }
    
    /// Stores on disk the failed step object
    ///
    /// - Parameter email:
    
    func createFailedStepObject(userId: String, steps: Double, timestamp: String)-> Void{
        let failedStep = FailedStep()
        failedStep.userId = userId
        failedStep.steps = steps
        failedStep.timestamp = timestamp
        
        let realm = try! Realm()
        
        try! realm.write{
            realm.add(failedStep)
            //print("[ Failed Step Object Created ] Steps: ", steps, "User Id: ", userId, "Timestamp: ", timestamp)
        }
    }
    
    /// ENDS CODE FROM POW THAT EXTRACTS THE BASELINE FOR NUMBER OF STEPS
    
    
}
