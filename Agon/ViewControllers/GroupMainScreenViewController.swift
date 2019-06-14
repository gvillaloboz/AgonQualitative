//
//  GroupMainScreenViewController.swift
//  Agon
//
//  Created by Gabriela Villalobos-Zúñiga on 08.02.19.
//  Copyright © 2019 UNIL. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class GroupMainScreenViewController : UIViewController{
    
    // Properties
    
    
    @IBOutlet weak var groupButton: UIButton!
    @IBOutlet weak var soloButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var instructionsTextField: UITextView!
    
    private let trialController = TrialController()
    let userController = UserController()
    var competitionStatus = Int()
    let healthKitSetupAssistant = HealthKitSetupAssistant()
    
    // Functions
    
    override func viewDidLoad(){
        hideUIComponents()
        styleTextView()
        styleButtons()
    }
    
    override func viewDidAppear(_ animated: Bool){
        self.competitionStatus = trialController.getTrialStatus()
        
        switch self.competitionStatus {
            
        case 0: // no running competition
            print("No running competition")
            self.instructionsTextField.text = "Would you like to participate in a group competition or would you prefer go on your own?"
            self.instructionsTextField.isHidden = false
            self.soloButton.isHidden = false
            self.groupButton.isHidden = false
            
        case 1: // running competition
            print("Running competition")
            groupButton.isHidden = true
            soloButton.isHidden = true
            okButton.isHidden = true
            performSegue(withIdentifier: "groupMainToGroupDashboardSegue", sender: self)
            
        default:
            print("No valid competition status")
        }
    }
    
    
    /// Hides the UI components for buttons
    /// and instructions text field
    func hideUIComponents(){
        okButton.isHidden = true
        instructionsTextField.isHidden = true
        soloButton.isHidden = true
        groupButton.isHidden = true
    }
    
    func styleTextView(){
        instructionsTextField.layer.backgroundColor = Color().getPurple()
        instructionsTextField.layer.cornerRadius = 5
        instructionsTextField.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        instructionsTextField.layer.borderWidth = 0.5
        instructionsTextField.clipsToBounds = true
        
    }
    
    func styleButtons(){

        soloButton.layer.cornerRadius = 5
        soloButton.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        soloButton.layer.borderWidth = 0.5
        soloButton.layer.backgroundColor = Color().getOrange()
        soloButton.setTitleColor(.white, for: .normal)
        
        groupButton.layer.cornerRadius = 5
        groupButton.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        groupButton.layer.borderWidth = 0.5
        groupButton.layer.backgroundColor = Color().getOrange()
        groupButton.setTitleColor(.white, for: .normal)
        
        okButton.layer.cornerRadius = 5
        okButton.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        okButton.layer.borderWidth = 0.5
        okButton.layer.backgroundColor = Color().getOrange()
        okButton.setTitleColor(.white, for: .normal)
        
    }
    
    @IBAction func soloMode(_ sender: Any) {
        print("Jump to solo mode")
        
        /// Request the user data
        let realm = try! Realm()
        if let user = realm.objects(RealmUserModel.self).first{
        
        // Creates new user with updated experimental condition and stores it on the realm
        userController.storeUserLocally(id: user.id, name: user.name, lastName: user.lastName, pseudonym: user.pseudonym, email: user.email, expCondition: "1" , completion: {
            status in
            
            /// Segues accordingly to experimental condition
            if(status){
                performSegue(withIdentifier: "groupToSoloSegue", sender: self)
            }})
        }
    }
    
    
    @IBAction func groupMode(_ sender: Any) {
        instructionsTextField.text = "You will be placed in a group of people with similar physical activity level. Each week you will compete with a different group of people. \n\n To win, make more steps than your opponent. \n\n The weekly challenge begins on Mondays at 00:00 hrs and ends on Sundays at 23:59 hrs."
        
        okButton.isHidden = false
        soloButton.isHidden = true
        groupButton.isHidden = true
        
        self.competitionStatus = 1
        
        assignToChallengeGroup()
    }
    
    
    @IBAction func okGroup(_ sender: Any) {
        print("OK to group")
        okButton.isHidden = true
        
        //Save competition status (goal) in the realm
//        trialController.storeTrialStatusLocally(weeklyGoal: 99999, status : self.trialStatus, d completion: { success in
//            print("Trial Status succesfully inserted in local realm")
//            print("Trial Status: \(competitionStatus)")
//        })
        
        performSegue(withIdentifier: "groupMainToGroupDashboardSegue", sender: self)
        
    }
    
    
    /// This function will assign a participant to an optimal competition group
    /// If it is the first assignment then it will consider just two weeks ago
    /// Next assignmnets will consider steps from the previous week exclusively
    func assignToChallengeGroup(){
        var userId : String
        var assignmentNumber : Int
        var daysBack = 7 // most of the time we will evaluate just one week ago to assign to a group
        var averageStepsForGroupAssignment : Double = 0.0
        
        // Gets the user Id
        let realm = try! Realm()
        if let user = realm.objects(RealmUserModel.self).first{
            userId = user.id
        }
        
        // Checks if this is the first assignment
        if let competition = realm.objects(RealmTrialModel.self).last{
            assignmentNumber = competition.assignment
            if assignmentNumber == 0 {
                daysBack = 14
            }
        }
        
        // Gets the weekly average steps of the last 2 weeks or of the last week
        healthKitSetupAssistant.getDailyAverageStepCount(numberOfSampleDays: daysBack) { (steps) in
            print("Average daily steps of the last \(daysBack / 7) weeks: ", steps)
            averageStepsForGroupAssignment = steps
        }
        
        // Assigns to a competition group in the DB and in the realm
        // There will always be 10 groups (this could be adjusted based on the number of participants)
        // The 10 competitions groups should already be created in the DB

        switch averageStepsForGroupAssignment {
            case 0...1000:
                print ("Range 0...1000")
                // insert in competitionGroup looking for physicalActivityLevel 0,1000
                //competitionController.insertIntoCompetitionGroup()
            case 1001...2000:
                print ("Range 1001...2000")
            case 2001...3000:
                print ("Range 2001...3000")
            case 3001...4000:
                print ("Range 3001...4000")
            case 4001...5000:
                print ("Range 4001...5000")
            case 5001...6000:
                print ("Range 5001...6000")
            case 6001...7000:
                print ("Range 6001...7000")
            case 7001...8000:
                print ("Range 7001...8000")
            case 8001...9000:
                print ("Range 8001...9000")
            case 9001...10000:
                print ("Range 9001...10000")
            default:
                print ("More than 10000")
        }
        
    }
    
    
}
