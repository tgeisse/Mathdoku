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
}
