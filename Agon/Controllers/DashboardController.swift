//
//  DashboardController.swift
//  Agon
//
//  Created by Gabriela Villalobos-Zúñiga on 26.12.18.
//  Copyright © 2018 UNIL. All rights reserved.
//

import Foundation

protocol DashboardContollerProtocol: class {
    //func userDataDownloaded(data : String)
}

class DashboardController {
    
    //properties
    weak var delegate : DashboardContollerProtocol!
    var realmUserModel = RealmUserModel()
    var numericalHelper = Numerical() // maybe I do not need to create an object of this class
    var synchronizationModel = SynchronizationModel()
    
    // Funtion to store past unsync steps on the server and today's steps until current time
    func storeStepsInWebServer(steps : Double){
        // Checks if there are new steps that should be store on the DB
        if(synchronizationModel.getLastSyncTimestamp() < Date() && synchronizationModel.getLastSyncSteps() != steps)
        {
            // Checks if there is internet connection available to avoid connectivity issues with the server
            var internetConnection = Reachability().isInternetAvailable()
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
            
            //print("response = \(response!)")
            
            let responseString =  String(data: data!, encoding: .utf8)
            
            print("respnseString = \(responseString!)")
            
            var splitString = [String]()
            splitString = (responseString?.components(separatedBy: "."))!
            completion(splitString[0])
            
            self.synchronizationModel.updateLastSyncTimestampAndSteps(steps: steps)
        }
        task.resume()
        
        
    }
}
