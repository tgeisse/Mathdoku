//
//  GameLoadingBar.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 1/28/18.
//  Copyright © 2018 Taylor Geisse. All rights reserved.
//

import UIKit

@IBDesignable
class GameLoadingBar: UIView {
    var completedItems: Int = 0 { didSet { updateBlockingLayerPosition() } }
    var totalItems: Int = 1
    var animationDuration = 0.1
    private let blockingLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializer()
    }
    
    private func initializer() {
        addGradientBackground()
        addBlockingLayer()
        addLoadingBarBorder()
    }
    
    private func addGradientBackground() {
        let colorLeft = ColorTheme.blue.dark.cgColor
        let colorRight = ColorTheme.blue.light.cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorLeft, colorRight]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = self.bounds
        self.layer.addSublayer(gradientLayer)
    }
    
    private func addLoadingBarBorder() {
        // create a rectange the size of the view for the loading border path
        let path = UIBezierPath(roundedRect: self.bounds, cornerRadius: 13.0)
        
        // create a mask of the rectangle
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
        
        // create a border around the loading border path
        let borderLayer = CAShapeLayer()
        borderLayer.path = path.cgPath
        borderLayer.lineWidth = 3.0
        borderLayer.strokeColor = UIColor.white.cgColor
        borderLayer.fillColor = nil
        
        self.layer.addSublayer(borderLayer)
    }
    
    private func addBlockingLayer() {
        // create a standard rectangle the size of the bar
        let path = UIBezierPath(rect: self.bounds)
        
        // create a shape layer of a solid black fill
        blockingLayer.path = path.cgPath
        blockingLayer.fillColor = UIColor.black.cgColor
        
        self.layer.addSublayer(blockingLayer)
    }

    private func updateBlockingLayerPosition() {
        if totalItems == 0 {
            return
        }
        let percentComplete = Double(completedItems) / Double(totalItems)
        
        DispatchQueue.main.async {  [weak self] in
            let offSet: CGFloat
            if let maxX = self?.bounds.maxX {
                offSet = CGFloat(percentComplete) * maxX
            } else {
                offSet = 10000
            }
            DebugUtil.print("Moving the Blocking Layer to \(percentComplete) with offset \(offSet) - \(self?.completedItems ?? 0) / \(self?.totalItems ?? 1)")
            
            UIView.animate(withDuration: self?.animationDuration ?? 0.1, delay: 0.0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
                self?.blockingLayer.position = CGPoint(x: offSet, y: 0.0)
            }, completion: nil)
        }
    }
}
