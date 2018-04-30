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
        static let dark = UIColor(red: 1.00, green: 0.70, blue: 0.42, alpha: 1.0)
    }
    /*
    struct button {
        static let light: ButtonColor = (ColorTheme.blue.light, ColorTheme.orange.dark)
        static let dark: ButtonColor = (ColorTheme.blue.dark, ColorTheme.orange.dark)
    }*/
    
    enum ThemeMode: Int {
        case regular = 1
        case night
    }
    
    static var themeMode: ThemeMode {
        return Defaults[.nightMode] ? .night : .regular
    }
    
    static var tableBackgroundColor: UIColor {
        switch themeMode {
        case .regular: return UIColor(red:0.94, green:0.94, blue:0.96, alpha:1.00)
        case .night: return UIColor(red:0.12, green:0.12, blue:0.12, alpha:1.00)
        }
    }
    
    static var backgroundColor: UIColor {
        switch themeMode {
        case .regular: return .white
        case .night: return .black
        }
    }
    
    static var borderColor: UIColor {
        switch themeMode {
        case .regular: return .darkGray
        case .night: return .lightGray
        }
    }
    
    static var textColor: UIColor {
        switch themeMode {
        case .regular: return .darkText
        case .night: return .lightText
        }
    }
}
