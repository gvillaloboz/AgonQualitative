//
//  FailedStep.swift
//  Agon
//
//  Created by Gabriela Villalobos-Zúñiga on 02.07.19.
//  Copyright © 2019 UNIL. All rights reserved.
//

import Foundation
import RealmSwift

final class FailedStep: Object{
    
    // MARK: - Properties
    @objc dynamic var userId = ""
    @objc dynamic var steps = 0.0
    @objc dynamic var timestamp = String()
}
