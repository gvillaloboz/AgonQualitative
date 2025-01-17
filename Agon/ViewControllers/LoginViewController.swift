//
//  LoginViewController.swift
//  Agon
//
//  Created by Gabriela Villalobos on 08.11.18.
//  Copyright © 2018 UNIL. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class LoginViewController : UIViewController, UserContollerProtocol, UITextFieldDelegate{

    // MARK: - Properties
    var userData: String = String()
    // FIXME:  no estoy segura si se está bien declarar e inicializar este controller aquí. En el tutorial estaba en el viewDidLoad(), pero yo necesito tener acceso desde que hago click
    let userController = UserController()
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        styleButtons()
        messageLabel.text = " "
        messageLabel.textColor = UIColor.red
        
        // set delegates and initialize controllers
        userController.delegate = self
        emailTextField.delegate = self
        
        self.setupHideKeyboardOnTap()
    }
    
    
    /// Function that handles the start button press
    ///
    /// - Parameter sender: the start button on the Login View
    @IBAction func startButtonPress(_ sender: UIButton) {
        
        if(!isEmailTextfieldEmpty()){

            // The if let is done to remove the optional
            if let actualEmail = emailTextField.text{
                userController.downloadUserData(email: actualEmail)
            }
            
        }
    }
    
    /// Receives the user data from the controller and handles it in the Login View
    ///
    /// - Parameter items: data User data from the web server
    func userDataDownloaded(data : String){
        userData = data
        if (userData == "0 results"){
            messageLabel.text = "Correo electrónico no registrado en el sistema."
        }
        else{
            userController.storeUserLocally(data: data, completion: {
                status in
                
                /// Segues accordingly to experimental condition 
                if(status){
                    /// Request user experimental condition
                    let realm = try! Realm()
                    let userExperimentalCondition = Int((realm.objects(RealmUserModel.self).first?.expCondition)!)!
                    
                    switch userExperimentalCondition {
                    case 1: // Autonomy
                        self.performSegue(withIdentifier: "loginToMainScreenSegue", sender: self)
                    case 2: // Autonomy + Competence
                        self.performSegue(withIdentifier: "loginToMainScreenSegue", sender: self)
                    case 3: // Autonomy + Competence + Relatedness
                        self.performSegue(withIdentifier: "loginToMainScreenSegue", sender: self)
                    default:
                        print("No experimental condition that allows Segueing")
                    }
                }
            })
            
        }
    }
    
    
    /// Checks if the textfield for the email is empty
    /// If it is, displays a message
    func isEmailTextfieldEmpty() -> Bool{
        if emailTextField.text?.isEmpty ?? true {
            messageLabel.text = "Escriba un correo electrónico"
            return true
        }
        else{return false}
    }

    
    /// Moves to the pseudonym textfield after hiting return from the email textfield
    ///
    /// - Parameter textField: email textfield
    /// - Returns: always true
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            textField.resignFirstResponder()
        }
        return true
    }

    /// Gives style to the button of the UI
    func styleButtons(){
        startButton.layer.cornerRadius = 5
        startButton.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        startButton.layer.borderWidth = 0.5
        startButton.layer.backgroundColor = Color().getOrange()
        startButton.setTitleColor(.white, for: .normal)
    }
}

// MARK: - Extension

extension UIViewController {
    /// Call this once to dismiss open keyboards by tapping anywhere in the view controller
    func setupHideKeyboardOnTap() {
        self.view.addGestureRecognizer(self.endEditingRecognizer())
        self.navigationController?.navigationBar.addGestureRecognizer(self.endEditingRecognizer())
    }
    
    /// Dismisses the keyboard from self.view
    private func endEditingRecognizer() -> UIGestureRecognizer {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing(_:)))
        tap.cancelsTouchesInView = false
        return tap
    }
}
