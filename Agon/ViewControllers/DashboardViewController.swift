//
//  DashboardViewController.swift
//  Agon
//
//  Created by Gabriela Villalobos on 02.11.18.
//  Copyright © 2018 UNIL. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController, HealthKitSetupAssistantProtocol, shareHealthDataDelegate {
    
    // Properties
    
    @IBOutlet weak var weeklyGoalLabel: UILabel!
    @IBOutlet weak var dailyGoalLabel: UILabel!
    @IBOutlet weak var dailyStepsLabel: UILabel!
    
    let healthkitSetupAssistant = HealthKitSetupAssistant()
    let delegate = UIApplication.shared.delegate as! AppDelegate
    let dashboardController = DashboardController()
    

    
    // Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("Dashboard view did load")
        
        // Request today step counts to HK and display
        healthkitSetupAssistant.getTodayStepCount(completion: {dailySteps in
            print("Steps requested from Dashboard: \(dailySteps)")
            self.dailyStepsLabel.text = "Steps for today: \(dailySteps)"
        })
        
//        guard  let mainScreenViewController = self.storyboard?.instantiateViewController(withIdentifier: "MainScreenViewController")
//            as? MainScreenViewController else {
//            fatalError("View Controller not found")
//        }
        var mainScreenViewController = MainScreenViewController()
        mainScreenViewController.delegate = self //Protocol conformation here
        
        /// request to realm the daily goal
        self.dailyGoalLabel.text = "Daily Goal: 123"
        self.weeklyGoalLabel.text = "Weekly Goal: 999"
        
        // set delegates and initialize controllers
        //dashboardController.delegate = self


//        healthkitSetupAssistant.delegate = self
//        stepCountLabel.text = String(healthkitSetupAssistant.stepsFromBackground)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Functions
    func userStepsRetrieved(steps: Double) {
        
    }
    
    func downloadWeeklyGoal(weeklyStepsGoal: Double){
        self.weeklyGoalLabel.text = String(weeklyStepsGoal)
    }

    
}

