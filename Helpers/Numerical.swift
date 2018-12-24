//
//  Numerical.swift
//  Agon
//
//  Created by Gabriela Villalobos-Zúñiga on 10.12.18.
//  Copyright © 2018 UNIL. All rights reserved.
//

import Foundation


extension Double
{
    func truncate(places : Int)-> Double
    {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}
