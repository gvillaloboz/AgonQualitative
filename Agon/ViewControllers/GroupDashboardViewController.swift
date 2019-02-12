//
//  GroupDashboardViewController.swift
//  Agon
//
//  Created by Gabriela Villalobos-Zúñiga on 08.02.19.
//  Copyright © 2019 UNIL. All rights reserved.
//

import Foundation
import UIKit

class GroupDashboardViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    struct StepsRecord{
        var stepsNumber : String
        var timestamp : String
    }
    
    // Properties
    @IBOutlet weak var weeklyGoalLabel: UILabel!
    @IBOutlet weak var dailyGoalLabel: UILabel!
    @IBOutlet weak var dailyStepsLabel: UILabel!
    @IBOutlet weak var historyButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let animals = ["Cat", "Dog", "Cow", "Mulval"]
    
    // Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleUI()
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
            return animals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = animals[indexPath.row]
        //cell.textLabel?.text = "Section \(indexPath.section) Row \(indexPath.row)"
        return cell
    }
    
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 3
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 5
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//
//        cell.textLabel?.text = "Section \(indexPath.section) Row \(indexPath.row)"
//        //cell.stepsNumberLabel?.text = "steps number"
//        //cell.timestampLabel?.text = "timestamp"
//
//        return cell
//    }
//
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "Section \(section)"
//    }
//
}
