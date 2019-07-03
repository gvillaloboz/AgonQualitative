//
//  Sync.swift
//  Agon
//
//  Created by Gabriela Villalobos-Zúñiga on 02.07.19.
//  Copyright © 2019 UNIL. All rights reserved.
//

import Foundation
import RealmSwift

final class Sync: Object{
    
    // MARK: - Properties
    @objc dynamic var timestamp = Date()
}
