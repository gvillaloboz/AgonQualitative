//
//  MainScreenViewController.swift
//  Agon
//
//  Created by Gabriela Villalobos on 22.11.18.
//  Copyright © 2018 UNIL. All rights reserved.
//

/// Image credits: competition by pictohaven from the Noun Project

import Foundation
import UIKit
import HealthKit
import RealmSwift

protocol shareHealthDataDelegate : class {
    func downloadWeeklyGoal(weeklyStepsGoal : Double)
}

class MainScreenViewController : UIViewController  { //HealthKitDataRetrieverProtocol
    
    // Properties
    
    @IBOutlet weak var numberOfStepsLabel: UILabel!
    @IBOutlet weak var instructionsTextField: UITextView!
    
    @IBOutlet weak var acceptGoalButton: UIButton!
    @IBOutlet weak var denyGoalButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    
    private let healthkitSetupAssistant = HealthKitSetupAssistant()
    private let competitionController = CompetitionController()
    private let dashboardController = DashboardController()
    
    var competitionStatus = Int()
    var weeklyGoal = Double()
    var averageDailySteps = Double()
    
    weak var delegate : shareHealthDataDelegate?
    
    // Functions
    override func viewDidLoad() {
        hideUIComponents()
    }
    
    override func viewDidAppear(_ animated: Bool){
        
        //dashboardController.delegate = self
        
        /// get the competition status from Realm
        /// no running competition 0
        /// running competition 1
        self.competitionStatus = competitionController.getCompetitionStatus()
        
        switch self.competitionStatus {
        case 0:
            print("No running competition")
            forkBasedOnExperimentalCondition()
        case 1:
            print("Running competition")
            denyGoalButton.isHidden = true
            acceptGoalButton.isHidden = true
            performSegue(withIdentifier: "mainToDashboardSegue", sender: self)
            
            // Request today step counts to HK and display
//            healthkitSetupAssistant.getTodayStepCount(completion: {dailySteps in
//                self.instructionsTextField.text = "Steps for today: \(dailySteps)"
//            })
        default:
            print("No valid competition status")
        }
    }
    
    func stepCountsDownloaded(data: String) {
        print("Call to steps data downloaded")
    }
    

    
    
    func forkBasedOnExperimentalCondition(){
        /// request user experimental condition and average steps
        let realm = try! Realm()
        let userExperimentalCondition = Int((realm.objects(RealmUserModel.self).first?.expCondition)!)!
    
        healthkitSetupAssistant.getDailyAverageStepCount(completion: {averageSteps in
        
        self.averageDailySteps = averageSteps.truncate(places: 2)
            
        /// based on experimental group set instructions text
        var instructionsText = ""
        
        switch userExperimentalCondition {
        case 1: /// individual
            self.instructionsTextField.text = "Your daily aveage steps is \(self.averageDailySteps). Do you want to increase it by 5%? That is walking \((self.averageDailySteps * 0.05).truncate(places: 2)) more steps or about \((self.averageDailySteps *  0.05 * 0.013).truncate(places: 2)) minutes of walking."
            self.instructionsTextField.isHidden = false
            self.acceptGoalButton.isHidden = false
            self.denyGoalButton.isHidden = false
            
        case 2: /// group
            self.instructionsTextField.text = "Would you like to participate in a group competition or would you prefer go on your own?"
        default:
            instructionsText = "There was error in the experimental group."
            }})
        }
    
    @IBAction func acceptGoalButtonAction(_ sender: Any) {
        let weeklyGoal = (self.averageDailySteps * 7) + (self.averageDailySteps * 0.05)
        instructionsTextField.text = "Your goal this week will be to reach \((weeklyGoal).truncate(places: 0)) steps. That is approximately \((weeklyGoal / 7).truncate(places: 0)) steps in one day."
        
        self.weeklyGoal = weeklyGoal
        self.competitionStatus = 1
        
        acceptGoalButton.isHidden = true
        denyGoalButton.isHidden = true
        okButton.isHidden = false
    }
     
    
    @IBAction func denyGoalButtonAction(_ sender: Any) {
        instructionsTextField.text = "It is fine! Let's try to keep your average number of steps as the goal for this week, that is \(self.averageDailySteps) steps."
        
        self.weeklyGoal = self.averageDailySteps
        self.competitionStatus = 1
        
        denyGoalButton.isHidden = true
        acceptGoalButton.isHidden = true
        okButton.isHidden = false
    }
    
    @IBAction func okButtonAction(_ sender: Any) { ///add timestamp to competition status
        //Save competition status (goal) in the realm
        competitionController.storeCompetitionStatusLocally(weeklyGoal: self.weeklyGoal, status : self.competitionStatus, completion: { success in
            print("Competition Status succesfully inserted in local realm")
            print("Weekly Goal: \(weeklyGoal)")
            print("Competition Status: \(competitionStatus)")
        })
        
        // Hide ok Button
        okButton.isHidden = true
        
        // Request today step counts to HK and display
        healthkitSetupAssistant.getTodayStepCount(completion: {dailySteps in
            self.instructionsTextField.text = "Steps for today: \(dailySteps)"
        })
        
        // Send weekly steps goal to DashboardViewController
        delegate?.downloadWeeklyGoal(weeklyStepsGoal: self.weeklyGoal)
        
        performSegue(withIdentifier: "mainToDashboardSegue", sender: self)
        //dashboardController.sendWeeklyGoal(self.weeklyGoal)
        
    }
   
    func hideUIComponents(){
        okButton.isHidden = true
        acceptGoalButton.isHidden = true
        denyGoalButton.isHidden = true
        instructionsTextField.isHidden = true
    }
    
}
