//
//  Ring.swift
//  Agon
//
//  Created by Gabriela Villalobos-Zúñiga on 23.01.19.
//  Copyright © 2019 UNIL. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class Ring : UIView {
    
    @IBInspectable var mainColor: UIColor = UIColor.blue
        {
        didSet { print("mainColor was set here") }
    }
    @IBInspectable var ringColor: UIColor = UIColor.orange
        {
        didSet { print("bColor was set here") }
    }
    @IBInspectable var ringThickness: CGFloat = 4
        {
        didSet { print("ringThickness was set here") }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect)
    {
        drawRingFittingInsideView()
    }
    
    internal func drawRingFittingInsideView()->(){
        
        let halfSize:CGFloat = min( bounds.size.width/2, bounds.size.height/2)
        let desiredLineWidth:CGFloat = 4
        
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x:halfSize,y:halfSize),
            radius: CGFloat( halfSize - (desiredLineWidth/2) ),
            startAngle: CGFloat(0),
            endAngle:CGFloat(Double.pi * 2),
            clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.strokeColor = UIColor.init(red: 81, green: 159, blue: 56, alpha: 1).cgColor
        shapeLayer.lineWidth = desiredLineWidth
        
        layer.addSublayer(shapeLayer)
    }
}
