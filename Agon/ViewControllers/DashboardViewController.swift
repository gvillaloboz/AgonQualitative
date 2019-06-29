//
//  DashboardViewController.swift
//  Agon
//
//  Created by Gabriela Villalobos on 02.11.18.
//  Copyright © 2018 UNIL. All rights reserved.
//

import UIKit
import RealmSwift

class DashboardViewController: UIViewController, HealthKitSetupAssistantProtocol, shareHealthDataDelegate, DashboardContollerProtocol, UITableViewDataSource, UITableViewDelegate {
    

    // Struct
    
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
    var leaderboardArray = [LeaderboardRecord]()
    
    
//    var leaderboardArray = [
//        LeaderboardRecord(userName : "Fred Durst", stepsNumber : "4432", kudo : "0"),
//        LeaderboardRecord(userName : "Sandra Cohen", stepsNumber : "14563", kudo : "1"),
//        LeaderboardRecord(userName : "Christina Aguilera", stepsNumber : "21", kudo : "1"),
//        LeaderboardRecord(userName : "Stephanie Dupont", stepsNumber : "3000", kudo : "0")
//    ]
    
    // Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dashboardController.delegate = self
        healthKitSetupAssistant.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
        // Check experimental condition to show/hide History button and Ranking
        /// Request user experimental condition
        let realm = try! Realm()
        let userExperimentalCondition = Int((realm.objects(RealmUserModel.self).last?.expCondition)!)!
        switch userExperimentalCondition {
        case 1:
            historyButton.isHidden = true
            tableView.isHidden = true
        case 2:
            styleUI()
            tableView.isHidden = true
        case 3:
            styleUI()
            dashboardController.downloadUsersListPerCondition(expCondition: "3")
            

        
        //loadLeaderboard()
        default:
             print( "There was error in the experimental group.")
        }
       
        
        
        
        // Request today step counts to HK and display
        healthKitSetupAssistant.getTodayStepCount(completion: {dailySteps in
            print("Steps requested from Dashboard: \(dailySteps)")
            self.dailyStepsLabel.text = "Pasos de hoy: \n\n \(Int(dailySteps))"
            
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
        //let realm = try! Realm()
        if let trialInfo = realm.objects(RealmTrialModel.self).last {
            self.dailyGoalLabel.text = "Objetivo Diario: \(Int(trialInfo.weeklyGoal / 7))"
            self.weeklyGoalLabel.text = "Objetivo Semanal: \(Int (trialInfo.weeklyGoal))"
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
            self.dailyStepsLabel.text = "Pasos de hoy: \r \(Int(dailySteps))"
            
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
        self.dailyStepsLabel.text = "bg Pasos de hoy: \r \(Int(steps))"
    }
    
    
    
    /// Attempt to update steps label when backgroud mode
    ///
    /// - Parameter steps: <#steps description#>
    func updateStepsLabelFunc(steps: String) {
        self.dailyStepsLabel.text = "Steps2 for today: \r \(Int(steps) ?? 99999)"
    }
    
    func userListPerConditionDataDownloaded(jsonArray: [[String:Any]]) {
        for dic in jsonArray{
            guard let name = dic["name"] as? String else { return }
            print(name)
            
            leaderboardArray.append(LeaderboardRecord(userName : name, stepsNumber : "4432", kudo : "0"))
            self.tableView.reloadData()
            //self.refresher.endRefreshing()
        }
    }
    
    
    /// Gives style to the history button
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
    
//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
//    }
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return TableData.count
//    }
    
    
    func loadLiderboard(){
        tableView.isHidden = false
    }
    
    func refreshLeaderboard(){
        
    }

}
