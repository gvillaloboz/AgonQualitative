//
//  LoginViewController.swift
//  Agon
//
//  Created by Gabriela Villalobos on 08.11.18.
//  Copyright © 2018 UNIL. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController : UIViewController, UserContollerProtocol, UITextFieldDelegate{

    // Properties
    var userData: String = String()
    var user : UserModel = UserModel()
    // no estoy segura si se está bien declarar e inicializar este controller aquí. En el tutorial estaba en el viewDidLoad(), pero yo necesito tener acceso desde que hago click
    let userController = UserController()
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var pseudonymTextField: UITextField!
    @IBOutlet weak var messageLabel: UILabel!
    
    // Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        messageLabel.text = " "
        messageLabel.textColor = UIColor.red
        
        // set delegates and initialize controllers
        userController.delegate = self
        // this function i added to test passing a parameter, but when the view loads i do not have the email yet
        //userController.downloadItems(email : "gavizu@gmail.com")
        
        emailTextField.delegate = self
        pseudonymTextField.delegate = self
        //emailTextField.tag = 0
        
        // Looks for single or multiple taps
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
//        view.addGestureRecognizer(tap)
    }
    
    
    /// Function that handles the start button press
    ///
    /// - Parameter sender: the start button on the Login View
    @IBAction func startButtonPress(_ sender: UIButton) {
        
        if(!isEmailTextfieldEmpty() && !isPseudonymTextfieldEmpty()){

            // The if let is done to remove the optional
            if let actualEmail = emailTextField.text{
                userController.downloadUserData(email: actualEmail)
            }
            
            if let actualPesudonym = pseudonymTextField.text{
                print("Pseudonym:", actualPesudonym)
                userController.setPseudonym(pseudonym: actualPesudonym)
            }
        }
    }
    
    /// Receives the user data from the controller and handles it in the Login View
    ///
    /// - Parameter items: data User data
    func userDataDownloaded(data : String){
        userData = data
        if (userData == "0 results"){
            messageLabel.text = "Email not registered in the system"
        }
        else{
            self.performSegue(withIdentifier: "loginToMainScreenSegue", sender: self)
            userController.storeUserLocally(data: data, pseudonym:  pseudonymTextField.text!)
        }
    }
    
    
    /// Checks if the textfield for the pseudonym is empty
    /// If it is, displays a message
    func isPseudonymTextfieldEmpty() -> Bool{
        if pseudonymTextField.text?.isEmpty ?? true {
            messageLabel.text = "Type a pseudonym"
            return true
        }
        else{
            print("Pseudonym text: ", pseudonymTextField.text!)
            return false
        }
    }
    
    /// Checks if the textfield for the email is empty
    /// If it is, displays a message
    func isEmailTextfieldEmpty() -> Bool{
        if emailTextField.text?.isEmpty ?? true {
            messageLabel.text = "Type an email"
            return true
        }
        else{
            print("Email text: ", pseudonymTextField.text!)
            return false
        }
    }
    
    
    
    /// Moves to the pseudonym textfield after hiting return from the email textfield
    ///
    /// - Parameter textField: email textfield
    /// - Returns: always true
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            textField.resignFirstResponder()
            pseudonymTextField.becomeFirstResponder()
        }
        else if textField == pseudonymTextField {
            textField.resignFirstResponder()
        }
        return true
    }
    
    
    /// Function called when a tap is recognized.
    /// Causes the view (or one of its embedded text fields) to resign the first responder status
    func dismissKeyboard(){
        view.endEditing(true)
    }
    
    
    ////// This functions I can remove later ////

//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // Return the number of feed items
//        return feedItems.count
//
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        // Retrieve cell
//        let cellIdentifier: String = "BasicCell"
//        let myCell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)!
//        // Get the location to be shown
//        let item: UserModel = feedItems[indexPath.row] as! UserModel
//        // Get references to labels of cell
//        myCell.textLabel!.text = item.name
//
//        return myCell
//    }
    
}
