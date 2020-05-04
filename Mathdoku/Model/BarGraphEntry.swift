//
//  BarGraphEntry.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 4/8/20.
//  Copyright © 2020 Taylor Geisse. All rights reserved.
//

import UIKit

struct BarGraphEntry {
    let origin: CGPoint
    let barWidth: CGFloat
    let barHeight: CGFloat
    let space: CGFloat
    
    var barFrame: CGRect {
        return CGRect(x: origin.x, y: origin.y, width: barWidth, height: barHeight)
    }
}
