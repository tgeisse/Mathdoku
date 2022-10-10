//
//  DoubleExtension.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 10/7/22.
//  Copyright © 2022 Taylor Geisse. All rights reserved.
//

import Foundation

extension Double {
    var convertToTimeString: String {
        let ti = TimeInterval(self)
        return String(format: "%02i:%02i:%02i", ti.hours, ti.minutes, ti.seconds)
    }
}
