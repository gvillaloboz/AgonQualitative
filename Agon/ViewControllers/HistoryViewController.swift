//
//  HistoryViewController.swift
//  Agon
//
//  Created by Gabriela Villalobos-Zúñiga on 21.01.19.
//  Copyright © 2019 UNIL. All rights reserved.
//

import Foundation
import UIKit

class HistoryViewController : UITableViewController, HistoryContollerProtocol{
    
    struct StepsRecord{
        var stepsNumber : String
        var timestamp : String
    }
    
    var historyController = HistoryController()
    var userModel = RealmUserModel()
    var historyArray : [StepsRecord] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        historyController.delegate = self
        historyController.downloadAllHistoryData(userId: userModel.getId())
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyArray.count
    }
 
    
    /// Create cells according to the Prototype cell and configure the cell text to show the section and row numbers
    ///
    /// - Parameters:
    ///   - tableView: table view
    ///   - indexPath: position in the table
    /// - Returns: the table view cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! HistoryTableViewCell
        cell.stepsNumberLabel?.text = historyArray[indexPath.row].stepsNumber
        cell.timestampLabel?.text = historyArray[indexPath.row].timestamp
       
        //print(historyArray[indexPath.row].stepsNumber + "\t" + historyArray[indexPath.row].timestamp)
    
        return cell
    }
    
    
    /// Returns a title according to the section number
    ///
    /// - Parameters: 
    ///   - tableView: <#tableView description#>
    ///   - section: <#section description#>
    /// - Returns: title according to the section number
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "Section \(section)"
//    }
    
    // Prints the content of the history retrieved from the server [Temporal]
    func userAllHistoryDataDownloaded(data: String) {
        var rawStringRecordArray = data.components(separatedBy: "\n")
        rawStringRecordArray.remove(at: rawStringRecordArray.count-1)
        //historyArray = data.components(separatedBy: "\n")
        //rawStringRecordArray.forEach{ (rawRecord) in
        for (index, rawRecord) in rawStringRecordArray.enumerated(){
            var temp = rawRecord.components(separatedBy: ",")
            let stepsRecord = StepsRecord(stepsNumber: temp[0], timestamp : temp[1])
        
            historyArray.append(stepsRecord)
        
        }
        
        tableView.reloadData()

        
    }
    
}
