//
//  TimeIntervalExtension.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 6/13/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import Foundation

extension TimeInterval {
    @available(*, deprecated, message: "To reduce calculations, move to each individual properties")
    var components: (weeks: Int, days: Int, hours: Int, minutes: Int, seconds: Int, ms: Int) {
        
        let ti = NSInteger(self)
        
        let ms = Int(self.truncatingRemainder(dividingBy: 1) * 1000)
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        let days = (ti / 86400)
        let weeks = (ti / 604800)
        
        return (weeks, days, hours, minutes, seconds, ms)
    }
    
    private var int:Int     { return NSInteger(self) }
    var ms:         Int     { return Int(self.truncatingRemainder(dividingBy: 1) * 1000) }
    var seconds:    Int     { return int % 60 }
    var minutes:    Int     { return (int / 60) % 60 }
    var hours:      Int     { return int / 3600 }
    var days:       Int     { return int / 86400 }
    var weeks:      Int     { return int / 604800 }
}
