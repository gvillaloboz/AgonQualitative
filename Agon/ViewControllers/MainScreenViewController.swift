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


class MainScreenViewController : UIViewController, HealthKitDataRetrieverProtocol {
    
    // Properties
    
    @IBOutlet weak var numberOfStepsLabel: UILabel!
    @IBOutlet weak var instructionsTextField: UITextView!
    
    @IBOutlet weak var acceptGoalButton: UIButton!
    @IBOutlet weak var denyGoalButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    
    private let healthkitSetupAssistant = HealthKitSetupAssistant()
    private let competitionController = CompetitionController()
    
    
    var competitionStatus = Int()
    var weeklyGoal = Double()
    var averageWeeklySteps = Double()
    
    // Functions
    override func viewDidLoad() {
        okButton.isHidden = true
        //acceptGoalButton.isHidden = true
        //denyGoalButton.isHidden = true
        
//        healthkitSetupAssistant.getStepsOnDate(completion: {steps in
//            print("STEPS: \(steps)")
//            self.numberOfStepsLabel.text = String(format: "%f", steps)
//
//        })
        
        // get the competition status from Realm
        // no running competition 0
        // running competition 1
        
        self.competitionStatus = 0
        
        switch competitionStatus {
        case 0:
            print("No running competition")
            forkBasedOnExperimentalCondition()
        case 1:
            print("Running competition")
        default:
            print("No valid competition status")
        }

        
        /// get the steps from last month
//        let monthsToSubstract = -1
//        let currentDate = Date()
//
//        var dateComponent = DateComponents()
//
//        dateComponent.month = monthsToSubstract
//
//        let pastDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)
        
//        print("Current date:  \(currentDate)")
//        print("Past date: \(pastDate!)")
//        healthkitSetupAssistant.requestStepsToHKWithCompletion(start: pastDate!, end: Date()) { (steps) in
//            print ("STEPS FROM LAST MONTH: \(steps)")
//        }
        
        //healthkitSetupAssistant.getNStepsBack(daysBack: 10)
        
    }
    
    func stepCountsDownloaded(data: String) {
        print("Call to steps data downloaded")
    }
    

    
    
    func forkBasedOnExperimentalCondition(){
        /// request user experimental condition and average steps
        let realm = try! Realm()
        let userExperimentalCondition = Int((realm.objects(RealmUserModel.self).first?.expCondition)!)!
    
        healthkitSetupAssistant.getWeeklyAverageStepCount(completion: {averageSteps in
        
        self.averageWeeklySteps = averageSteps.truncate(places: 2)
            
        /// based on experimental group set instructions text
        var instructionsText = ""
        
        switch userExperimentalCondition {
        case 1: /// individual
            self.instructionsTextField.text = "Your daily aveage steps is \(self.averageWeeklySteps). Do you want to increase it by 5%? That is walking \((self.averageWeeklySteps * 0.05).truncate(places: 2)) more steps or about \((self.averageWeeklySteps *  0.05 * 0.013).truncate(places: 2)) minutes of walking."
        case 2: /// group
            self.instructionsTextField.text = "Would you like to participate in a group competition or would you prefer go on your own?"
        default:
            instructionsText = "There was error in the experimental group."
            }})
        }
    
    @IBAction func acceptGoalButtonAction(_ sender: Any) {
        let weeklyGoal = self.averageWeeklySteps + self.averageWeeklySteps * 0.05
        instructionsTextField.text = "Your goal this week will be to reach \((weeklyGoal).truncate(places: 0)) steps. That is approximately \((weeklyGoal / 7).truncate(places: 0)) steps in one day."
        
        self.weeklyGoal = weeklyGoal
        self.competitionStatus = 1
        
        acceptGoalButton.isHidden = true
        denyGoalButton.isHidden = true
        okButton.isHidden = false
    }
    
    
    @IBAction func denyGoalButtonAction(_ sender: Any) {
        instructionsTextField.text = "It is fine! Let's try to keep your average number of steps as the goal for this week, that is 42000 steps."
        
        denyGoalButton.isHidden = true
        acceptGoalButton.isHidden = true
        okButton.isHidden = false
    }
    
    @IBAction func okButtonAction(_ sender: Any) {
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
    }
    
    
}
