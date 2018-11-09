//
//  LoginViewController.swift
//  Agon
//
//  Created by Gabriela Villalobos on 08.11.18.
//  Copyright © 2018 UNIL. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController : UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var pseudonymTextField: UITextField!

    @IBAction func startButtonPress(_ sender: UIButton) {
        if let actualEmail = emailTextField.text{
            print("Email:",actualEmail)
        }
        
        if let actualPesudonym = pseudonymTextField.text{
            print("Pseudonym:", actualPesudonym)
        }
    }
}
