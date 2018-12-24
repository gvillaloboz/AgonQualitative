//
//  MainScreenViewController.swift
//  Agon
//
//  Created by Gabriela Villalobos on 22.11.18.
//  Copyright © 2018 UNIL. All rights reserved.
//

import Foundation
import UIKit
import HealthKit


class MainScreenViewController : UIViewController, HealthKitDataRetrieverProtocol {
    
    // Properties
    
    @IBOutlet weak var numberOfStepsLabel: UILabel!
    @IBOutlet weak var instructionsTextField: UITextView!
    
    @IBOutlet weak var acceptGoalButton: UIButton!
    @IBOutlet weak var denyGoalButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    
    private let healthkitSetupAssistant = HealthKitSetupAssistant()
    
    var competitionStatus = 1
    
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
        if competitionStatus == 1 { /// competition running
         performSegue(withIdentifier: "mainToDashboardSegue", sender: self)
        }
        else{
            self.forkBasedOnExperimentalGroup()
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
    

    
    
    func forkBasedOnExperimentalGroup(){
        /// request user experimental group and average steps
        let userExperimentalGroup = 1
        healthkitSetupAssistant.getWeeklyAverageStepCount(completion: {averageSteps in
        
        var averageStepsTruncate = averageSteps.truncate(places: 2)
            
        /// based on experimental group set instructions text
        var instructionsText = ""
        
        switch userExperimentalGroup {
        case 1: /// individual
            self.instructionsTextField.text = "Your daily aveage steps is \(averageStepsTruncate). Do you want to increase it by 5%? That is walking \(averageStepsTruncate * 0.05) more or about \(averageStepsTruncate * 0.013) minutes of walking."
        case 2:
            self.instructionsTextField.text = "Would you like to participate in a group competition or would you prefer go on your own?"
        default:
            instructionsText = "There was error in the experimental group."
            }})
        }
    
    @IBAction func acceptGoalButtonAction(_ sender: Any) {
        instructionsTextField.text = "Your goal this week will be to reach 44100 steps. That is approximately 6300 steps in one day."
        
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
//        healthkitSetupAssistant.getTodayStepCount(completion: {steps in
//            let dash = DashboardViewController()
//            dash.setStepCountLabel(stepCountLabel: steps)
//        })
        
    }
    
    
}
