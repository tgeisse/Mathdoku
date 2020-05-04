//
//  CustomDrawingStructs.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 4/8/20.
//  Copyright © 2020 Taylor Geisse. All rights reserved.
//

import UIKit

struct LineSegment {
    let startPoint: CGPoint
    let endPoint: CGPoint
}

struct HorizontalLine {
    let segment: LineSegment
    let isDashed: Bool
    let width: CGFloat
}
