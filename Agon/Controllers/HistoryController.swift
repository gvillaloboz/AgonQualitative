//
//  HistoryController.swift
//  Agon
//
//  Created by Gabriela Villalobos-Zúñiga on 30.01.19.
//  Copyright © 2019 UNIL. All rights reserved.
//

import Foundation
import RealmSwift

protocol HistoryContollerProtocol: class {
    func userAllHistoryDataDownloaded(data : String)
}

class HistoryController{
    
    
    // MARK: - Properties
    let urlPath : String = "https://pow.unil.ch/agon/phpScripts/selectStepsHistory.php"
    weak var delegate : HistoryContollerProtocol!
    
    // MARK: - Functions
    /// Downloads from agon db in pow.unil.ch the steps history data
    ///
    /// - Parameter userId: user identification
    func downloadAllHistoryData(userId : String){
        
        let url: URL = URL(string :  urlPath)!
        let defaultSession = Foundation.URLSession(configuration : URLSessionConfiguration.default)
        
        var urlRequest : URLRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        let postString = "a=\(userId)"
        urlRequest.httpBody = postString.data(using: .utf8)
        
        let postTask = defaultSession.dataTask(with: urlRequest){data, response, error in
            guard let data = data, error == nil else {  // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 { // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            let responseString = String(data: data, encoding: .utf8)!
            //print("responseString = \(String(describing: responseString))")
            
            DispatchQueue.main.async(execute: { () -> Void  in
                // Sends user data to the delegate function on the Login View
                self.delegate.userAllHistoryDataDownloaded(data: responseString)
            })
        }
        
        postTask.resume();
        
    }
    
    /// Might remove this function, there is one on the user model controller
    func getUserModel() -> String{
        let realm = try! Realm()
        var userId = ""
        
        if (!realm.objects(RealmUserModel.self).isEmpty){
            userId = (realm.objects(RealmUserModel.self).last?.id)!
        }
        return userId
    }
    
}
