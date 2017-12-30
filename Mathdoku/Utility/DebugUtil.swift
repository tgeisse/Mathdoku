//
//  DebugPrint.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 5/30/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import Foundation

struct DebugUtil {
    static func print(_ items: Any..., separator: String = " ", terminator: String = "\n", function: String = #function) {
        #if DEBUG
    
            
            var idx = items.startIndex
            let endIdx = items.endIndex
            let date = Date()
            let calendar = Calendar.current
            let dateString = String(format: "%0.2d:%0.2d:%0.2d", calendar.component(.hour, from: date), calendar.component(.minute, from: date), calendar.component(.second, from: date))
            
            repeat {
                Swift.print("Mathdoku.\(function) \(dateString): \(items[idx])", separator: separator, terminator: idx == (endIdx - 1) ? terminator : separator)
                idx += 1
            }
                while idx < endIdx
            
        #endif
    }
}
