//
//  CheckLoginViewController.swift
//  Agon
//
//  Created by Gabriela Villalobos on 06.11.18.
//  Copyright © 2018 UNIL. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class CheckLoginViewController : UIViewController{
    
    //Check if user is already created on disk
    override func viewDidAppear(_ animated: Bool) {
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
