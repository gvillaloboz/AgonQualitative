//
//  GroupMainScreenViewController.swift
//  Agon
//
//  Created by Gabriela Villalobos-Zúñiga on 08.02.19.
//  Copyright © 2019 UNIL. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class GroupMainScreenViewController : UIViewController{
    
    // Properties
    
    
    @IBOutlet weak var groupButton: UIButton!
    @IBOutlet weak var soloButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var instructionsTextField: UITextView!
    let userController = UserController()
    
    // Functions
    
    override func viewDidLoad(){
        hideUIComponents()
        styleTextView()
        styleButtons()
    }
    
    override func viewDidAppear(_ animated: Bool){
        self.instructionsTextField.text = "Would you like to participate in a group competition or would you prefer go on your own?"
        self.instructionsTextField.isHidden = false
        self.soloButton.isHidden = false
        self.groupButton.isHidden = false
    }
    
    
    /// Hides the UI components for buttons
    /// and instructions text field
    func hideUIComponents(){
        okButton.isHidden = true
        instructionsTextField.isHidden = true
        soloButton.isHidden = true
        groupButton.isHidden = true
    }
    
    func styleTextView(){
        instructionsTextField.layer.backgroundColor = Color().getPurple()
        instructionsTextField.layer.cornerRadius = 5
        instructionsTextField.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        instructionsTextField.layer.borderWidth = 0.5
        instructionsTextField.clipsToBounds = true
        
    }
    
    func styleButtons(){

        soloButton.layer.cornerRadius = 5
        soloButton.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        soloButton.layer.borderWidth = 0.5
        soloButton.layer.backgroundColor = Color().getOrange()
        soloButton.setTitleColor(.white, for: .normal)
        
        groupButton.layer.cornerRadius = 5
        groupButton.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        groupButton.layer.borderWidth = 0.5
        groupButton.layer.backgroundColor = Color().getOrange()
        groupButton.setTitleColor(.white, for: .normal)
        
        okButton.layer.cornerRadius = 5
        okButton.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        okButton.layer.borderWidth = 0.5
        okButton.layer.backgroundColor = Color().getOrange()
        okButton.setTitleColor(.white, for: .normal)
        
    }
    
    @IBAction func soloMode(_ sender: Any) {
        print("Jump to solo mode")
        
        /// Request the user data
        let realm = try! Realm()
        if let user = realm.objects(RealmUserModel.self).first{
        
        // Creates new user with updated experimental condition and stores it on the realm
        userController.storeUserLocally(id: user.id, name: user.name, lastName: user.lastName, pseudonym: user.pseudonym, email: user.email, expCondition: "1" , completion: {
            status in
            
            /// Segues accordingly to experimental condition
            if(status){
                performSegue(withIdentifier: "groupToSoloSegue", sender: self)
            }})
        }
    }
    
    
    @IBAction func groupMode(_ sender: Any) {
        instructionsTextField.text = "You will be placed in a group of people with similar physical activity level. Each week you will compete with a different group of people. \n To win, make more steps than your opponent. \n The weekly challenge begins on Mondays at 00:00 hrs and ends on Sundays at 23:59 hrs."
        
        okButton.isHidden = false
        soloButton.isHidden = true
        groupButton.isHidden = true
    }
    
    
    @IBAction func okGroup(_ sender: Any) {
        print("OK to group")
        okButton.isHidden = true
        performSegue(withIdentifier: "groupMainToGroupDashboardSegue", sender: self)
        
    }
    
    
}
