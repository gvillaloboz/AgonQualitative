//
//  UserModel.swift
//  Agon
//
//  Created by Gabriela Villalobos on 13.11.18.
//  Copyright © 2018 UNIL. All rights reserved.
//

import Foundation

class UserModel : NSObject{
    
    // properties
    
    var name : String?
    var lastName : String?
    var email : String?
    
    // empty constructor
    
    override init(){
        
    }
    
    // constructor with @name, @email parameters
    
    init(name : String, email : String){
        self.name = name
        self.email = email
        
    }
    
    // prints object's current state
    
    override var description: String {
        return "Name: \(name), Email: \(email)"
    }
}
