//
//  ColorTheme.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 1/11/18.
//  Copyright © 2018 Taylor Geisse. All rights reserved.
//

import UIKit

// typealias ButtonColor = (background: UIColor, text: UIColor)

struct ColorTheme {
    struct green {
        static let light = UIColor(hex: 0x83FD84)
        static let bright = UIColor.green
        static let dark = UIColor.init(red:0.0, green: 0.60, blue: 0.0, alpha: 1.0)
    }
    
    struct red {
        static let light = UIColor(hex: 0xFD7F80)
        static let bright = UIColor.red
        static let dark = UIColor.red
    }
    
    struct blue {
        static let light = UIColor(hex: 0x7a91ff)
        static let dark = UIColor(hex: 0x2C3872)
    }
    
    struct orange {
        static let light = UIColor(red: 0.99, green: 0.90, blue: 0.80, alpha: 1.0)
        static let dark = UIColor(hex: 0xFBC176)
        //static let dark = UIColor(red: 1.00, green: 0.70, blue: 0.42, alpha: 1.0)
    }
    /*
    struct button {
        static let light: ButtonColor = (ColorTheme.blue.light, ColorTheme.orange.dark)
        static let dark: ButtonColor = (ColorTheme.blue.dark, ColorTheme.orange.dark)
    }*/
}
