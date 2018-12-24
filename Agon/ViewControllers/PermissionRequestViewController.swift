//
//  PermissionRequestViewController.swift
//  Agon
//
//  Created by Gabriela Villalobos on 20.11.18.
//  Copyright © 2018 UNIL. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class PermissionRequestViewController : UIViewController {
 
    // Properties
    let healthKitSetupAssistant =  HealthKitSetupAssistant()
    
    // Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
    }
    
    //Check if user is already created on disk
    override func viewDidAppear(_ animated: Bool) {
//        let realm = try! Realm()
//        var matchedUsers = realm.objects(RealmUserModel.self)
//        if (!matchedUsers.isEmpty){
//            //print("User already logged in!!!!")
//            performSegue(withIdentifier: "splashToMainSegue", sender: self)
//            print(matchedUsers[0])
//        }
//        else{
//            performSegue(withIdentifier: "splashToLoginSegue", sender: self)
//        }
    }
    
    @IBAction func OKButton(_ sender: Any) {
        print("Tap on OK button")
        
        let group = DispatchGroup()
        group.enter()
        
        DispatchQueue.main.async {
            //self.authorizeHealthKit()
            //HealthKitSetupAssistant.authorizeHealthKit2()
            group.leave()
        }
        
        group.notify(queue: .main){
            print("Move to next screen")
            self.moveToNextScreen()
        }
    }
    
    
    private func authorizeHealthKit() {
    
        healthKitSetupAssistant.authorizeHealthKit { (authorized, error) in
            
            guard authorized else {
                
                let baseMessage = "HealthKit Authorization Failed"
                
                if let error = error {
                    print("\(baseMessage). Reason: \(error.localizedDescription)")
                } else {
                    print(baseMessage)
                }
                
                return
            }
            
            print("HealthKit Successfully Authorized.")
            
        }
    }
    
    private func moveToNextScreen(){
        let realm = try! Realm()
        var matchedUsers = realm.objects(RealmUserModel.self)
        if (!matchedUsers.isEmpty){
            //print("User already logged in!!!!")
            performSegue(withIdentifier: "splashToMainSegue", sender: self)
            print(matchedUsers[0])
        }
        else{
            performSegue(withIdentifier: "splashToLoginSegue", sender: self)
        }
    }
    
}
