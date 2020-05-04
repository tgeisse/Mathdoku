//
//  CALayerExtensions.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 5/1/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import UIKit

extension CALayer {
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {

        let border = CALayer()
        
        switch edge {
        case UIRectEdge.top:
            border.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: thickness)
            break
        case UIRectEdge.bottom:
            border.frame = CGRect.init(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
            break
        case UIRectEdge.left:
            border.frame = CGRect.init(x: 0, y: 0, width: thickness, height: frame.height)
            break
        case UIRectEdge.right:
            border.frame = CGRect.init(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
            break
        default:
            break
        }
        
        border.backgroundColor = color.cgColor;
        
        self.addSublayer(border)
    }
    
    func addCorner(corner: UIRectCorner, color: UIColor, edgeLenth: CGFloat) {
        let cornerBox = CALayer()
        
        switch corner {
        case .topLeft:
            cornerBox.frame = CGRect.init(x: 0, y: 0, width: edgeLenth, height: edgeLenth)
        case .topRight:
            cornerBox.frame = CGRect.init(x: frame.width - edgeLenth, y: 0, width: edgeLenth, height: edgeLenth)
        case .bottomRight:
            cornerBox.frame = CGRect.init(x: frame.width - edgeLenth, y: frame.height - edgeLenth, width: edgeLenth, height: edgeLenth)
        case .bottomLeft:
            cornerBox.frame = CGRect.init(x: 0, y: frame.height - edgeLenth, width: edgeLenth, height: edgeLenth)
        default:
            break
        }
        
        cornerBox.backgroundColor = color.cgColor
        
        self.addSublayer(cornerBox)
    }
    
    func addLineLayer(lineSegment: LineSegment, color: CGColor, width: CGFloat, isDashed: Bool, animated: Bool, oldSegment: LineSegment? = nil) {
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(lineSegment: lineSegment).cgPath
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = color
        layer.lineWidth = width
        if isDashed {
            layer.lineDashPattern = [4, 4]
        }
        self.addSublayer(layer)
        
        if animated, let segment = oldSegment {
            layer.animate(
                fromValue: UIBezierPath(lineSegment: segment).cgPath,
                toValue: layer.path!,
                keyPath: "path")
        }
    }
    
    func addRectangleLayer(frame: CGRect, color: CGColor, oldFrame: CGRect?, animated: Bool = false) {
        let layer = CALayer()
        layer.frame = frame
        layer.backgroundColor = color
        self.addSublayer(layer)
        
        if animated, let oldFrame = oldFrame {
            layer.animate(fromValue: CGPoint(x: oldFrame.midX, y: oldFrame.midY), toValue: layer.position, keyPath: "position")
            layer.animate(fromValue: CGRect(x: 0, y: 0, width: oldFrame.width, height: oldFrame.height), toValue: layer.bounds, keyPath: "bounds")
        }
    }
    
    func animate(fromValue: Any, toValue: Any, keyPath: String, timingFunction: CAMediaTimingFunctionName = .default, duration: Double = 0.2) {
        
        let animation = CABasicAnimation(keyPath: keyPath)
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: timingFunction)
        self.add(animation, forKey: keyPath)
    }
}
