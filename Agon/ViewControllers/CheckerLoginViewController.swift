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
    
    
    // Properties
    @IBOutlet weak var messageTextView: UITextView!
    let userController = UserController()
    let healthKitSetupAssistant = HealthKitSetupAssistant()
    
    
    override func viewDidAppear(_ animated: Bool) { //override func viewDidLoad(){
        super.viewDidAppear(animated)
        print("Checker View did appear")

            if(userController.checkIfUserExistsLocally()){
                performSegue(withIdentifier: "splashToMainSegue", sender: self)
            }
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
    
    @objc func buttonAction(sender: UIButton!) {
        let group = DispatchGroup()
        group.enter()
        
        DispatchQueue.main.async {
            self.authorizeHealthKitButtonCall()
            group.leave()
        }
        
        group.notify(queue: .main){
            print("Move to next screen")
            HealthKitSetupAssistant.checkHealthKitAuthorization()
            self.moveToNextScreen()
        }
//        let btnsendtag: UIButton = sender
//        if btnsendtag.tag == 1 {
//
//            dismiss(animated: true, completion: nil)
//            print("blue button pressed");
//        }
    }
    
    
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
