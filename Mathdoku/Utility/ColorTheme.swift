//
//  ColorTheme.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 1/11/18.
//  Copyright © 2018 Taylor Geisse. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

// typealias ButtonColor = (background: UIColor, text: UIColor)

class ColorTheme {
    enum Themes: Int, CustomStringConvertible, CaseIterable {
        case normal = 0
        case darkMode = 1
        case midnight = 2
        
        var description: String {
            switch self {
            case .normal: return "Normal"
            case .darkMode: return "Dark Mode"
            case .midnight: return "Midnight"
            }
        }
    }
    
    static var sharedInstance = ColorTheme()
    
    var theme: Themes
    
    init(theme: Themes? = nil) {
        self.theme = theme ?? Themes(rawValue: Defaults[\.colorTheme]) ?? .normal
    }
    
    func updateTheme(byInt themeId: Int) {
        let newTheme = Themes(rawValue: themeId) ?? .normal
        Defaults[\.colorTheme] = newTheme.rawValue
        theme = newTheme
    }
    
    func reloadTheme() {
        theme = Themes(rawValue: Defaults[\.colorTheme]) ?? .normal
    }
    
    var background: UIColor {
        switch theme {
        case .normal: return .white
        case .darkMode: return UIColor(hex: 0x212129)
        case .midnight: return .black
        }
    }
    
    var border: UIColor {
        switch theme {
        case .normal: return .black
        case .darkMode: return .white
        case .midnight: return .darkGray
        }
    }
    
    var fonts: UIColor {
        switch theme {
        case .normal: return .black
        case .darkMode: return .white
        case .midnight: return .darkGray
        }
    }
    
    var cellNumers: UIColor {
        switch theme {
        case .normal: return .black
        case .darkMode: return .white
        case .midnight: return .darkGray
        }
    }
    
    var selectedCell: UIColor {
        switch theme {
        case .normal: return ColorTheme.orange.dark
        case .darkMode: return ColorTheme.orange.dark
        case .midnight: return ColorTheme.orange.dark
        }
    }
    
    var friendlyCell: UIColor {
        switch theme {
        case .normal: return ColorTheme.orange.light
        case .darkMode: return ColorTheme.orange.light
        case .midnight: return ColorTheme.orange.light
        }
    }
    
    var invalidCell: UIColor {
        switch theme {
        case .normal: return ColorTheme.red.light
        case .darkMode: return ColorTheme.red.light
        case .midnight: return ColorTheme.red.light
        }
    }
    
    var validCell: UIColor {
        switch theme {
        case .normal: return ColorTheme.green.light
        case .darkMode: return ColorTheme.green.light
        case .midnight: return ColorTheme.green.light
        }
    }
    
    var possibleNote: UIColor {
        switch theme {
        case .normal: return ColorTheme.green.dark
        case .darkMode: return ColorTheme.green.dark
        case .midnight: return ColorTheme.green.dark
        }
    }
    
    var possibleNoteCellSelected: UIColor {
        return validCell
    }
    
    var impossibleNote: UIColor {
        switch theme {
        case .normal: return ColorTheme.red.light
        case .darkMode: return ColorTheme.red.light
        case .midnight: return ColorTheme.red.light
        }
    }
    
    var impossibleNoteCellSelected: UIColor {
        return invalidCell
    }
    
    var allegianceEqual: UIColor{
        switch theme {
        case .normal: return ColorTheme.green.bright
        case .darkMode: return ColorTheme.green.bright
        case .midnight: return ColorTheme.green.bright
        }
    }
    
    var allegianceConflict: UIColor{
        switch theme {
        case .normal: return ColorTheme.red.bright
        case .darkMode: return ColorTheme.red.bright
        case .midnight: return ColorTheme.red.bright
        }
    }
    
    var puzzleCompleteAndCountdown: UIColor {
        switch theme {
        case .normal: return ColorTheme.blue.dark
        case .darkMode: return ColorTheme.blue.dark
        case .midnight: return ColorTheme.blue.dark
        }
    }
    
    var positiveTextLabel: UIColor {
        switch theme {
        case .normal: return ColorTheme.green.dark
        case .darkMode: return ColorTheme.green.dark
        case .midnight: return ColorTheme.green.dark
        }
    }
    
    private class green {
        static let light = UIColor(hex: 0x83FD84)
        static let bright = UIColor.green
        static let dark = UIColor(red:0.0, green: 0.60, blue: 0.0, alpha: 1.0)
    }
    
    private class red {
        static let light = UIColor(hex: 0xFD7F80)
        static let bright = UIColor.red
        static let dark = UIColor.red
    }
    
    private class blue {
        static let light = UIColor(hex: 0x7a91ff)
        static let dark = UIColor(hex: 0x2C3872)
    }
    
    private class orange {
        //static let light = UIColor(red: 0.99, green: 0.90, blue: 0.80, alpha: 1.0)
        static let light = UIColor(hex: 0xFFEFD3)
        static let dark = UIColor(hex: 0xFBC176)
        //static let dark = UIColor(red: 1.00, green: 0.70, blue: 0.42, alpha: 1.0)
    }
    /*
    struct button {
        static let light: ButtonColor = (ColorTheme.blue.light, ColorTheme.orange.dark)
        static let dark: ButtonColor = (ColorTheme.blue.dark, ColorTheme.orange.dark)
    }*/
}
