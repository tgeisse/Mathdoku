//
//  BarChartDrawer.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 4/8/20.
//  Copyright © 2020 Taylor Geisse. All rights reserved.
//

import UIKit

class BarChartDrawer {
    // margins
    private let barWidth: CGFloat
    private let spacing: CGFloat
    private let bottomSpace: CGFloat = 40.0
    private let topSpace: CGFloat = 40.0
    
    
    init(barWidth: CGFloat = 4.0, spacing: CGFloat = 2.0) {
        self.barWidth = barWidth
        self.spacing = spacing
    }
}
