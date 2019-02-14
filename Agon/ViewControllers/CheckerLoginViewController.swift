//
//  CheckerLoginViewController.swift
//  Agon
//
//  Created by Gabriela Villalobos on 06.11.18.
//  Copyright © 2018 UNIL. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class CheckerLoginViewController : UIViewController{
    
    // MARK: - Properties
    let userController = UserController()
    let healthKitSetupAssistant = HealthKitSetupAssistant()
    

    // MARK: - Functions
    
    /// Verifies if the user exists in the local realm
    /// in this case it means that the user has previously logged into the system
    /// If the user exists locally then the CheckerLoginViewController checks the
    /// the experimental condition and segues accordingly to the MainScreenViewController or GroupMainScreenViewController
    /// If the user does not exists then the CheckerLoginViewController segues to the LoginViewController
    ///
    /// - Parameter animated:
    override func viewDidAppear(_ animated: Bool) { //override func viewDidLoad(){
        super.viewDidAppear(animated)
        print("Checker View did appear")

            // Forks based on Experimental Condition and takes the last
            // user object because of the ability of group users to swith
            // from experimental conditions
        
            // Login occured previously (user created on local realm)
            if(userController.checkIfUserExistsLocally()){
                // Request user experimental condition
                let realm = try! Realm()
                let userExperimentalCondition = Int((realm.objects(RealmUserModel.self).last?.expCondition)!)!
                
                switch userExperimentalCondition {
                case 1: // individual
                    performSegue(withIdentifier: "splashToMainSegue", sender: self)
                case 2: // group
                    performSegue(withIdentifier: "splashToGroupMainSegue", sender: self)
                default:
                    print("There was error in the experimental group.")
                }
            }
            // No Login yet (user does not exist on local realm)
            else{
                performSegue(withIdentifier: "splashToLoginSegue", sender: self)
            }
            
        //}
//        else{
//            messageTextView.text = "We need your permission to access your steps data and to send you a notification once in a while."
//            // var button   = UIButton.buttonWithType(UIButtonType.System) as UIButton
//            let button = UIButton(type: .system) // let preferred over var here
//            button.frame = CGRect(x: 100, y: 100, width: 100, height: 50)
//            button.backgroundColor = UIColor.blue
//            button.setTitle("Accept", for: UIControl.State.normal)
//            button.addTarget(self, action: #selector (buttonAction), for: UIControl.Event.touchUpInside)
//            button.tag = 1
//            self.view.addSubview(button)
//
//        }
    }
    
//    @objc func buttonAction(sender: UIButton!) {
//        let group = DispatchGroup()
//        group.enter()
//
//        DispatchQueue.main.async {
//            self.authorizeHealthKitButtonCall()
//            group.leave()
//        }
//
//        group.notify(queue: .main){
//            print("Move to next screen")
//            HealthKitSetupAssistant.checkHealthKitAuthorization()
//            self.moveToNextScreen()
//        }
////        let btnsendtag: UIButton = sender
////        if btnsendtag.tag == 1 {
////
////            dismiss(animated: true, completion: nil)
////            print("blue button pressed");
////        }
//    }
    
    
    private func authorizeHealthKitButtonCall() {
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
    
    func showNilError() {
                
        let alert = UIAlertController(title: "No Heart Rate Data Found", message: "There was no heart rate data found for the selected ... Please go to the settings app (Privacy -> HealthKit) to change this.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Go to settings", style: .default, handler:  { action in
            if let url = URL(string:UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }            }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
