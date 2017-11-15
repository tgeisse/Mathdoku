//
//  StoreProductContainerView.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 6/12/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import UIKit

@IBDesignable
class StoreProductContainerView: UIView {
    @IBInspectable var borderColor = UIColor.black.cgColor
        { didSet { setNeedsDisplay() } }
    @IBInspectable var fillColor = UIColor.white.cgColor
        { didSet { setNeedsDisplay() } }
    @IBInspectable var borderWidth: CGFloat = 2
        { didSet { setNeedsDisplay() } }
    
    override func draw(_ rect: CGRect) {
        // draw the outside
        drawRoundedRect(rect, color: borderColor)
        
        // draw the inside rectange to create a border
        drawRoundedRect(rect, color: fillColor, subtractWidth: borderWidth, subtractHeight: borderWidth)
    }
    
    func drawRoundedRect(_ rect: CGRect, color: CGColor, subtractWidth: CGFloat = 0, subtractHeight: CGFloat = 0) {
        // Size of rounded rectangle
        let rectWidth = rect.width - subtractWidth
        let rectHeight = rect.height - subtractHeight
        
        // Find center of actual frame to set rectangle in middle
        let xf:CGFloat = (self.frame.width  - rectWidth)  / 2
        let yf:CGFloat = (self.frame.height - rectHeight) / 2
        
        let ctx: CGContext = UIGraphicsGetCurrentContext()!
        ctx.saveGState()
        
        let rect = CGRect(x: xf, y: yf, width: rectWidth, height: rectHeight)
        let clipPath: CGPath = UIBezierPath(roundedRect: rect, cornerRadius: 9.0).cgPath
        
        ctx.addPath(clipPath)
        ctx.setFillColor(color)
        
        ctx.closePath()
        ctx.fillPath()
        ctx.restoreGState()
    }
}
