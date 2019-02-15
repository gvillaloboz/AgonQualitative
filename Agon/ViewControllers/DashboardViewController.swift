//
//  DashboardViewController.swift
//  Agon
//
//  Created by Gabriela Villalobos on 02.11.18.
//  Copyright © 2018 UNIL. All rights reserved.
//

import UIKit
import RealmSwift

class DashboardViewController: UIViewController, HealthKitSetupAssistantProtocol, shareHealthDataDelegate, DashboardContollerProtocol {

    
    // Properties
    
    @IBOutlet weak var weeklyGoalLabel: UILabel!
    @IBOutlet weak var dailyGoalLabel: UILabel!
    @IBOutlet weak var dailyStepsLabel: UILabel!
    @IBOutlet weak var historyButton: UIButton!
    
    let healthKitSetupAssistant = HealthKitSetupAssistant()
    let dashboardController = DashboardController()

    
    // Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        styleUI()
        dashboardController.delegate = self
        healthKitSetupAssistant.delegate = self
        
        
        // Request today step counts to HK and display
        healthKitSetupAssistant.getTodayStepCount(completion: {dailySteps in
            print("Steps requested from Dashboard: \(dailySteps)")
            self.dailyStepsLabel.text = "Steps for today: \n\n \(Int(dailySteps))"
            
            // Store steps in the Agon DB Server
            self.dashboardController.storeStepsInWebServer(steps : dailySteps)
        })
    
//        guard  let mainScreenViewController = self.storyboard?.instantiateViewController(withIdentifier: "MainScreenViewController")
//            as? MainScreenViewController else {
//            fatalError("View Controller not found")
//        }
        //var mainScreenViewController = MainScreenViewController()
        //mainScreenViewController.delegate = self //Protocol conformation here
        
        /// request to realm the daily goal
        let realm = try! Realm()
        if let competitionInfo = realm.objects(RealmCompetitionModel.self).last {
            self.dailyGoalLabel.text = "Daily Goal: \(Int(competitionInfo.weeklyGoal / 7))"
            self.weeklyGoalLabel.text = "Weekly Goal: \(Int (competitionInfo.weeklyGoal))"
        }
        
//        ring = Ring()
//        ring.draw(CGRect.zero)
//        self.view.addSubview(ring)
        
        
        // set delegates and initialize controllers
        //dashboardController.delegate = self


//        healthkitSetupAssistant.delegate = self
//        stepCountLabel.text = String(healthkitSetupAssistant.stepsFromBackground)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Dashboard view did appear")
        healthKitSetupAssistant.delegate = self
        // Request today step counts to HK and display
        healthKitSetupAssistant.getTodayStepCount(completion: {dailySteps in
            print("Steps requested from Dashboard: \(dailySteps)")
            self.dailyStepsLabel.text = "Steps for today: \r \(Int(dailySteps))"
            
            // Store steps in the Agon DB Server
            self.dashboardController.storeStepsInWebServer(steps : dailySteps)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Functions
    func downloadWeeklyGoal(weeklyStepsGoal: Double){
        self.weeklyGoalLabel.text = String(weeklyStepsGoal)
    }

    
    //FIXME: Update steps label when detected a background update
    
    /// Called when there was a background update on the steps
    ///
    /// - Parameter steps: <#steps description#>
    func updateStepsNumberLabel(steps: Double) {
        self.dailyStepsLabel.text = "bg Steps for today: \r \(Int(steps))"
    }
    
    
    
    /// Attempt to update steps label when backgroud mode
    ///
    /// - Parameter steps: <#steps description#>
    func updateStepsLabelFunc(steps: String) {
        self.dailyStepsLabel.text = "Steps2 for today: \r \(Int(steps) ?? 99999)"
    }
    
    
    /// Gives style to the history button
    func styleUI(){
        historyButton.layer.cornerRadius = 5
        historyButton.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        historyButton.layer.borderWidth = 0.5
        historyButton.layer.backgroundColor = Color().getOrange()
        historyButton.setTitleColor(.white, for: .normal)
    }
    

}
