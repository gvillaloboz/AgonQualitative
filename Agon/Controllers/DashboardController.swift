//
//  DashboardController.swift
//  Agon
//
//  Created by Gabriela Villalobos-Zúñiga on 26.12.18.
//  Copyright © 2018 UNIL. All rights reserved.
//

import Foundation

protocol DashboardContollerProtocol: class {
    //func userDataDownloaded(data : String)
}

class DashboardController {
    
    //properties
    weak var delegate : DashboardContollerProtocol!
    
}
