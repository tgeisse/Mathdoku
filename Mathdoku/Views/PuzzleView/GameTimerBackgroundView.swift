//
//  GameTimerBackgroundView.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 12/31/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import UIKit

@IBDesignable
class GameTimerBackgroundView: UIView {
    @IBInspectable let dipWidth = CGFloat(150)
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        let curveWidth = dipWidth * 0.15
        // let curveControlPoint = (self.frame.height / 2) * 0.75
        
        let widthBorder = max((self.frame.width - dipWidth) / 2, CGFloat(0.0))
        let leftBorder = widthBorder
        let rightBorder = self.frame.width - widthBorder
        
        let top = CGFloat(0.0)
        let bottom = self.frame.height
        
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: leftBorder, y: top))
        path.addCurve(to: CGPoint(x: leftBorder + curveWidth, y: bottom),
                      controlPoint1: CGPoint(x: leftBorder + (curveWidth * 0.6), y: top),
                      controlPoint2: CGPoint(x: leftBorder + (curveWidth * 0.4), y: bottom))
        path.addLine(to: CGPoint(x: rightBorder - curveWidth, y: bottom))
        path.addCurve(to: CGPoint(x: rightBorder, y: top),
                      controlPoint1: CGPoint(x: rightBorder - (curveWidth * 0.4), y: bottom),
                      controlPoint2: CGPoint(x: rightBorder - (curveWidth * 0.6), y: top))
        path.close()
        
        ColorTheme.sharedInstance.background.setFill()
        path.fill()
        
        ColorTheme.sharedInstance.background.setStroke()
        path.stroke()
    }
}
