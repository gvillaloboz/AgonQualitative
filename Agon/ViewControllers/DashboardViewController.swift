//
//  DashboardViewController.swift
//  Agon
//
//  Created by Gabriela Villalobos on 02.11.18.
//  Copyright © 2018 UNIL. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController, HealthKitSetupAssistantProtocol {
    
    

    
    // Properties
    @IBOutlet weak var stepCountLabel: UILabel!
    let healthkitSetupAssistant = HealthKitSetupAssistant()
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("Dashboard view did load")

//        healthkitSetupAssistant.delegate = self
//        stepCountLabel.text = String(healthkitSetupAssistant.stepsFromBackground)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Functions
    
    func userStepsRetrieved(steps: Double) {
        stepCountLabel.text = String(steps)
    }
    
//    func setStepCountLabel(stepCountLabel: Double){
//        self.stepCountLabel.text =  String(stepCountLabel)
//        //let dashboard = DashboardViewController()
//        //dashboard.stepCountLabel.text = String(stepCountLabel)
//    }
    
}

