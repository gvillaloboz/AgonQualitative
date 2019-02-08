//
//  Color.swift
//  Agon
//
//  Created by Gabriela Villalobos-Zúñiga on 08.02.19.
//  Copyright © 2019 UNIL. All rights reserved.
//

import Foundation
import UIKit

class Color{
    
    
    // Properties
   
    //let orange = self.color.hexStringToUIColor(hex: "#FF9300").cgColor
    
    func getPurple() -> CGColor{
        let color = Color()
        var purple : CGColor
        purple = color.hexStringToUIColor(hex: "#9437FF").cgColor
        
        return purple
    }
    
    func getOrange() -> CGColor{
        var orange : CGColor
        orange = Color().hexStringToUIColor(hex: "#FF9300").cgColor
        return orange
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
