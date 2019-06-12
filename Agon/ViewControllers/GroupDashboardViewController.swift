//
//  GroupDashboardViewController.swift
//  Agon
//
//  Created by Gabriela Villalobos-Zúñiga on 08.02.19.
//  Copyright © 2019 UNIL. All rights reserved.
//

import Foundation
import UIKit

class GroupDashboardViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, DashboardContollerProtocol, HealthKitSetupAssistantProtocol {

    

    struct LeaderboardRecord{
        var userName : String
        var stepsNumber : String
        var kudo : String
    }
    
    // Properties
    @IBOutlet weak var weeklyGoalLabel: UILabel!
    @IBOutlet weak var dailyGoalLabel: UILabel!
    @IBOutlet weak var dailyStepsLabel: UILabel!
    @IBOutlet weak var historyButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let healthKitSetupAssistant = HealthKitSetupAssistant()
    let dashboardController = DashboardController()
    
    let animals = ["Cat", "Dog", "Cow", "Mulval"]
    
    var leaderboardArray = [
        LeaderboardRecord(userName : "Fred Durst", stepsNumber : "4432", kudo : "0"),
        LeaderboardRecord(userName : "Sandra Cohen", stepsNumber : "14563", kudo : "1"),
        LeaderboardRecord(userName : "Christina Aguilera", stepsNumber : "21", kudo : "1"),
        LeaderboardRecord(userName : "Stephanie Dupont", stepsNumber : "3000", kudo : "0")
    ]
    
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
            self.dailyStepsLabel.text = "Steps for today: \(Int(dailySteps))"
            
            // Store steps in the Agon DB Server
            self.dashboardController.storeStepsInWebServer(steps : dailySteps)
        })
        
        // Get Group Weekly Goal
        var weeklyGoal = 60000
    
        // Get Daily Goal
        //self.dailyGoalLabel.text = "Daily Goal: \(Int(competitionInfo.weeklyGoal / 7))"
        self.dailyGoalLabel.text = "Daily Goal: \(Int(weeklyGoal / 7))" // or divided by the remaining days of the week
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resource that can be recreated
    }
    
    func styleUI(){
        historyButton.layer.cornerRadius = 5
        historyButton.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        historyButton.layer.borderWidth = 0.5
        historyButton.layer.backgroundColor = Color().getOrange()
        historyButton.setTitleColor(.white, for: .normal)
    }
    
     // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return leaderboardArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! LeaderboardTableViewCell
        
        cell.userNameLabel?.text = leaderboardArray[indexPath.row].userName
        cell.stepsLabel?.text = leaderboardArray[indexPath.row].stepsNumber
        cell.kudoButton?.setTitle(leaderboardArray[indexPath.row].kudo, for: .normal)
    
        return cell
    }
    
    func updateStepsLabelFunc(steps: String) {
        self.dailyStepsLabel.text = "Steps for today: \r \(Int(steps) ?? 99999)"
    }
    
    func updateStepsNumberLabel(steps: Double) {
        self.dailyStepsLabel.text = "Steps for today: \r \(Int(steps))"
    }
    
    
    
}
