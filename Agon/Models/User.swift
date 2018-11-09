//
//  User.swift
//  Agon
//
//  Created by Gabriela Villalobos on 08.11.18.
//  Copyright © 2018 UNIL. All rights reserved.
//

import Foundation
import RealmSwift

class User : Object{
    // Properties
    @objc dynamic var id = ""
    @objc dynamic var name = ""
    @objc dynamic var lastName = ""
    @objc dynamic var pseudonym = ""
    @objc dynamic var email = ""
    
    // Init
    convenience init(email: String) {
        self.init()
    }
}
