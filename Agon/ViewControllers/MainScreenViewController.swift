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
    private let competitionController = CompetitionController()
    private let dashboardController = DashboardController()
    
    var competitionStatus = Int()
    var weeklyGoal = Double()
    var averageDailySteps = Double()
    
    weak var delegate : shareHealthDataDelegate?
    
    /// MARK: - Functions
    
    override func viewDidLoad() {
        hideUIComponents()
        styleTextView()
        styleButtons()
    }
    
    
    override func viewDidAppear(_ animated: Bool){
        
        //dashboardController.delegate = self
        //  get the competition status from Realm
        self.competitionStatus = competitionController.getCompetitionStatus()
        
        switch self.competitionStatus {
        
        case 0: // no running competition
            print("No running competition")
            forkBasedOnExperimentalCondition()
        
        case 1: // running competition
            print("Running competition")
            denyGoalButton.isHidden = true
            acceptGoalButton.isHidden = true
            performSegue(withIdentifier: "mainToDashboardSegue", sender: self)
            
        default:
            print("No valid competition status")
        }
    }
    
    
    /// <#Description#>
    ///
    /// - Parameter data: <#data description#>
    func stepCountsDownloaded(data: String) {
        print("Call to steps data downloaded")
    }
    

    
    
    /// Displays on screen the instructions based on the experimental condition
    /// The conditions are individual or group
    func forkBasedOnExperimentalCondition(){
        
        /// Request user experimental condition
        let realm = try! Realm()
        let userExperimentalCondition = Int((realm.objects(RealmUserModel.self).last?.expCondition)!)!
        
        /// Requests average steps
        healthkitSetupAssistant.getDailyAverageStepCount(completion: {averageSteps in
        
            self.averageDailySteps = averageSteps.truncate(places: 0)
            
            /// based on experimental group set instructions text
            
            switch userExperimentalCondition {
            case 1: /// individual
                self.instructionsTextField.text = "Your daily aveage steps is \(Int(self.averageDailySteps)). \n Do you want to increase it by 5%? \n That is walking \((Int(self.averageDailySteps * 0.05))) more steps or about \((self.averageDailySteps *  0.05 * 0.013).truncate(places: 2)) minutes of walking."
                self.instructionsTextField.isHidden = false
                self.acceptGoalButton.isHidden = false
                self.denyGoalButton.isHidden = false
                
            case 2: /// group
                self.instructionsTextField.text = "The system should never get me here"
                self.instructionsTextField.isHidden = false
//                self.soloButton.isHidden = false
//                self.groupButton.isHidden = false
            default:
                print( "There was error in the experimental group.")
                }
            
        })
        }
    
    
    /// Action for the accept button
    /// Calculates the weekly goal based on the average daily steps and
    /// displays it on the screen. Shows the OK button.
    ///
    /// - Parameter sender: accept button
    @IBAction func acceptGoalButtonAction(_ sender: Any) {
        let weeklyGoal = (self.averageDailySteps * 7) + (self.averageDailySteps * 0.05)
        instructionsTextField.text = "Your goal this week will be to reach \(Int(weeklyGoal)) steps. \n\n That is approximately \(Int(weeklyGoal / 7)) steps in one day."
        
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
    
    
    /// Saves the competition status and the weekly goal in the local realm
    /// Hides the ok button and segues to the Dashboard View Controller
    ///
    /// - Parameter sender: OK button
    @IBAction func okButtonAction(_ sender: Any) { ///add timestamp to competition status
        //Save competition status (goal) in the realm
        competitionController.storeCompetitionStatusLocally(weeklyGoal: self.weeklyGoal, status : self.competitionStatus, completion: { success in
            print("Competition Status succesfully inserted in local realm")
            print("Weekly Goal: \(weeklyGoal)")
            print("Competition Status: \(competitionStatus)")
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
    
}
