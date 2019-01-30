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
    
    var historyController = HistoryController()
    var userModel = RealmUserModel()
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
 
    
    /// Create cells according to the Prototype cell and configure the cell text to show the section and row numbers
    ///
    /// - Parameters:
    ///   - tableView: <#tableView description#>
    ///   - indexPath: <#indexPath description#>
    /// - Returns: the table view cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
        
        //cell.textLabel?.text = "Section \(indexPath.section) Row \(indexPath.row)"
        cell.textLabel?.text = "27.10 \t\t 3450"
        
    
        historyController.downloadAllHistoryData(userId: userModel.getId())
        
        return cell
    }
    
    
    /// Returns a title according to the section number
    ///
    /// - Parameters:
    ///   - tableView: <#tableView description#>
    ///   - section: <#section description#>
    /// - Returns: title according to the section number
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Section \(section)"
    }
    
    // Prints the content of the history retrieved from the server [Temporal]
    func userAllHistoryDataDownloaded(data: String) {
        print(data)
    }
    
}
