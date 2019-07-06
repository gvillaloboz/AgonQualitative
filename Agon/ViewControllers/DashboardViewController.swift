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
    
    // Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dashboardController.delegate = self
        healthKitSetupAssistant.delegate = self
        
        // To refresh background steps
        let appDelegate:AppDelegate = UIApplication.shared.delegate! as! AppDelegate
        appDelegate.dashboardViewController = self
        
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
            
        default:
             print( "There was error in the experimental group.")
        }
       
        // Request today step counts to HK and display
        healthKitSetupAssistant.getTodayStepCount(completion: {dailySteps in
            print("Steps requested from Dashboard: \(dailySteps)")
            self.dailyStepsLabel.text = "Pasos de hoy: \r \(Int(dailySteps))"
            
            // Store steps in the Agon DB Server
            self.dashboardController.storeStepsInWebServer(steps : dailySteps)
        })
        
        
        /// request to realm the daily goal
        //let realm = try! Realm()
        if let trialInfo = realm.objects(RealmTrialModel.self).last {
            self.dailyGoalLabel.text = "Objetivo Diario: \(Int(trialInfo.weeklyGoal / 7))"
            self.weeklyGoalLabel.text = "Objetivo Semanal: \(Int (trialInfo.weeklyGoal))"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Dashboard view did appear")
        healthKitSetupAssistant.delegate = self
        // Request today step counts to HK and display
        healthKitSetupAssistant.getTodayStepCount(completion: {dailySteps in
            print("Steps requested from Dashboard: \(dailySteps)")
            self.dailyStepsLabel.text = "Pasos de hoy: \r \(Int(dailySteps))"
            
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
        self.viewWillAppear(true)
        //dismiss(animated: true, completion: nil)
        
    }
    
    
    
    /// Attempt to update steps label when backgroud mode
    ///
    /// - Parameter steps: <#steps description#>
    func updateStepsLabelFunc(steps: Double) {
        self.dailyStepsLabel.text = "Steps de hoy: \r \(Int(steps))"
        self.viewWillAppear(true)
    }
    
    func userListPerConditionDataDownloaded(jsonArray: [[String:Any]]) {
        leaderboardArray.removeAll()
        for dic in jsonArray{
            guard let name = dic["name"] as? String else { return }
            guard let numSteps = dic["numSteps"] as? String else { return }
            print(name)
            leaderboardArray.append(LeaderboardRecord(userName : name, stepsNumber : numSteps, kudo : "0"))
            self.tableView.reloadData()
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Participante \t\t\t\t\t Pasos diarios"
    }
    
    func loadLiderboard(){
        tableView.isHidden = false
    }
    

}
