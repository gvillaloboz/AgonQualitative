//
//  DashboardController.swift
//  Agon
//
//  Created by Gabriela Villalobos-Zúñiga on 26.12.18.
//  Copyright © 2018 UNIL. All rights reserved.
//

import Foundation


protocol DashboardContollerProtocol: class {
    func updateStepsLabelFunc(steps : Double)
    func userListPerConditionDataDownloaded(jsonArray : [[String:Any]])
}

class DashboardController : NSObject, URLSessionDataDelegate {
    
    // Properties
    weak var delegate : DashboardContollerProtocol!
    var realmUserModel = RealmUserModel()
    var numericalHelper = Numerical() // maybe I do not need to create an object of this class
    var synchronizationModel = SynchronizationModel()
    let urlPath : String = "https://pow.unil.ch/agon/phpScripts/selectUsersListPerCondition.php"
    
    
    // Functions
    func updateStepsLabel(steps: Double){
         self.delegate?.updateStepsLabelFunc(steps: steps)
    }
    
    // Funtion to store past unsync steps on the server and today's steps until current time
    func storeStepsInWebServer(steps : Double){
        print("Store Steps in WebServer")
        // Checks if there are new steps that should be store on the DB
        if(synchronizationModel.getLastSyncTimestamp() < Date() &&
            synchronizationModel.getLastSyncSteps() != steps &&
            realmUserModel.getId() != "NoId"){
            
            // Checks if there is internet connection available to avoid connectivity issues with the server
            let internetConnection = Reachability().isInternetAvailable()
            // Send today's steps to the server
            if(Reachability().isInternetAvailable()){
                sendStepsDataToWebServer(steps : steps,
                                         userId : realmUserModel.getId(),
                                         timestamp : Numerical().convertDateToString(date: Date()),
                                         completion : { results in
                                            print (results)
                                        }
                                        )
            }
        }
    }
    
    
    
    // Send unsync steps to the server
    
    // Print that everything was done correctly

    
    func sendStepsDataToWebServer(steps : Double, userId : String, timestamp : String, completion : @escaping (String) -> Void){
        let request = NSMutableURLRequest(url: NSURL (string: "https://pow.unil.ch/agon/phpScripts/storeSteps.php")! as URL)
        request.httpMethod = "POST"
        
        // Convert Date to String
        let a = String(describing: timestamp)
        let backSlash = "\'"
        let timeString = backSlash + a + backSlash
        // End Convert Date to String
        // review si viene un "NoId"
        let postString = "a=\(steps)&b=\(userId)&c=\(timeString)"
        print(postString)
        
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest){
            data, response, error in
            
            if error != nil {
                print("error=\(error!)")
                var splitString = [String]()
                splitString = (String(describing: error).components(separatedBy: " "))
                completion(splitString[2])
                return
            }
            
            let responseString =  String(data: data!, encoding: .utf8)
            
            print("respnseString = \(responseString!)")
            
            var splitString = [String]()
            splitString = (responseString?.components(separatedBy: "."))!
            completion(splitString[0])
            
            self.synchronizationModel.updateLastSyncTimestampAndSteps(steps: steps)
        }
        task.resume()
     
    }
    
    /// Downloads from agon db in pow.unil.ch the list of users belonging to a particular condition
    ///
    /// - Parameter email: email imput on the login screen
    func downloadUsersListPerCondition(expCondition : String){
        
        let url: URL = URL(string :  urlPath)!
        let defaultSession = Foundation.URLSession(configuration : URLSessionConfiguration.default)
        
        var urlRequest : URLRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        let postString = "a=\(expCondition)"
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
            
            //JSON
            do{
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                print(jsonResponse) //Response result
                
                guard let jsonArray = jsonResponse as? [[String: Any]] else {
                    return
                }
                // Sends user list per condition data to the delegate function on the DashboardView Controller
                DispatchQueue.main.async(execute: { () -> Void  in
                    
                    self.delegate?.userListPerConditionDataDownloaded(jsonArray: jsonArray)
                })
                //print(jsonArray)
            }
            catch let parsingError {
                print("Error", parsingError)
            }
        }
        postTask.resume();
    }
    
}
