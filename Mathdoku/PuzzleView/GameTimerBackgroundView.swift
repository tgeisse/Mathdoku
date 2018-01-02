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
    override func draw(_ rect: CGRect) {
        // Drawing code
        let curvePointDifferential = (self.frame.width / 2) * 0.1
        let curveControlPoint = (self.frame.height / 2) * 0.05
        
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: 0.0, y: 0.0))
        path.addLine(to: CGPoint(x: curvePointDifferential, y: self.frame.height))
        path.addLine(to: CGPoint(x: self.frame.width - curvePointDifferential, y: self.frame.height))
        path.addLine(to: CGPoint(x: self.frame.width, y: 0.0))
        path.close()
        
        UIColor.white.setFill()
        path.fill()
    }
}
