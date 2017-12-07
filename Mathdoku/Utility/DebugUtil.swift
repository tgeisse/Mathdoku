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
            
            repeat {
                Swift.print("\(function): \(items[idx])", separator: separator, terminator: idx == (endIdx - 1) ? terminator : separator)
                idx += 1
            }
                while idx < endIdx
            
        #endif
    }
}
