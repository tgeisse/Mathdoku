//
//  UIBezierPathExtensions.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 4/8/20.
//  Copyright © 2020 Taylor Geisse. All rights reserved.
//

import UIKit

extension UIBezierPath {
    convenience init(lineSegment: LineSegment) {
        self.init()
        self.move(to: lineSegment.startPoint)
        self.addLine(to: lineSegment.endPoint)
    }
}
