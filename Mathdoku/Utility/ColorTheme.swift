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

class ColorTheme: ObservableObject {
    enum Themes: Int, CustomStringConvertible, CaseIterable {
        case light = 0
        case darkMode = 1
        case midnight = 2
        
        var description: String {
            switch self {
            case .light: return "Light Mode"
            case .darkMode: return "Dark Mode"
            case .midnight: return "Midnight"
            }
        }
    }
    
    static var sharedInstance = ColorTheme()
    
    @Published var theme: Themes
    
    init(theme: Themes? = nil) {
        self.theme = theme ?? Themes(rawValue: Defaults[\.colorTheme]) ?? .light
    }
    
    func updateTheme(_ theme: Themes) {
        Defaults[\.colorTheme] = theme.rawValue
        self.theme = theme
    }
    
    func updateTheme(_ theme: Int) {
        updateTheme(Themes(rawValue: theme) ?? .light)
    }
    
    func reloadTheme() {
        theme = Themes(rawValue: Defaults[\.colorTheme]) ?? .light
    }
    
    var background: UIColor {
        switch theme {
        case .light: return .white
        case .darkMode: return UIColor(hex: 0x212129)
        case .midnight: return .black
        }
    }
    
    var border: UIColor {
        switch theme {
        case .light: return .darkGray
        case .darkMode: return UIColor(hex: 0xF6F2E6)
        case .midnight: return UIColor(hex: 0x7F7F7F)
        }
    }
    
    var fonts: UIColor {
        switch theme {
        case .light: return .black
        case .darkMode: return .white // UIColor(hex: 0xF6F2E6)
        case .midnight: return .lightGray
        }
    }
    
    /*
    var cellNumbers: UIColor {
        switch theme {
        case .normal: return .black
        case .darkMode: return .white
        case .midnight: return .gray
        }
    }
     */
    
    var selectedCell: UIColor {
        switch theme {
        case .light: return orange(.dark)
        case .darkMode: return UIColor(hex: 0xB38958)
        case .midnight: return UIColor(hex: 0x8C6C48)
        }
    }
    
    var friendlyCell: UIColor {
        switch theme {
        case .light: return orange(.light)
        case .darkMode: return UIColor(hex: 0x4E4A43)
        case .midnight: return UIColor(hex: 0x3A3731)
        }
    }
    
    var invalidCell: UIColor {
        switch theme {
        case .light: return red(.light)
        case .darkMode: return red(.dark)
        case .midnight: return UIColor(hex: 0xAE1B05)
        }
    }
    
    var validCell: UIColor {
        switch theme {
        case .light: return green(.light)
        case .darkMode: return green(.dark)
        case .midnight: return UIColor(hex: 0x006200)
        }
    }
    
    var possibleNote: UIColor {
        switch theme {
        case .light: return green(.dark)
        case .darkMode: return green(.light)
        case .midnight: return green(.dark)
        }
    }
    
    var possibleNoteCellSelected: UIColor {
        return validCell
    }
    
    var impossibleNote: UIColor {
        switch theme {
        case .light: return red(.dark)
        case .darkMode: return red(.light)
        case .midnight: return red(.light)
        }
    }
    
    var impossibleNoteCellSelected: UIColor {
        return invalidCell
    }
    
    var allegianceEqual: UIColor{
        switch theme {
        case .light: return green(.bright)
        case .darkMode: return green(.bright)
        case .midnight: return green(.bright)
        }
    }
    
    var allegianceConflict: UIColor{
        switch theme {
        case .light: return red(.bright)
        case .darkMode: return red(.bright)
        case .midnight: return red(.light)
        }
    }
    
    var puzzleCompleteAndCountdown: UIColor {
        switch theme {
        case .light: return blue(.dark)
        case .darkMode: return blue(.light)
        case .midnight: return blue(.light)
        }
    }
    
    var positiveTextLabel: UIColor {
        switch theme {
        case .light: return green(.dark)
        case .darkMode: return green(.light)
        case .midnight: return green(.light)
        }
    }
    
    private enum Brightness {
        case light, bright, dark
    }
    
    private func green(_ brightness: Brightness) -> UIColor {
        switch brightness {
        case .light: return UIColor(hex: 0x83FD84)
        case .bright: return UIColor.green
        case .dark: return UIColor(red:0.0, green: 0.60, blue: 0.0, alpha: 1.0)
        }
    }
    
    private func red(_ brightness: Brightness) -> UIColor {
        switch brightness {
        case .light: return UIColor(hex: 0xFD7F80)
        case .bright: return UIColor.red
        case .dark: return UIColor.red
        }
    }
    
    private func blue(_ brightness: Brightness) -> UIColor {
        switch brightness {
        case .light, .bright: return UIColor(hex: 0x7a91ff)
        case .dark: return UIColor(hex: 0x2C3872)
        }
    }
    
    private func orange(_ brightness: Brightness) -> UIColor {
        switch brightness {
        case .light, .bright: return UIColor(hex: 0xFFEFD3)
        case .dark: return UIColor(hex: 0xFBC176)
        }
    }
    /*
    struct button {
        static let light: ButtonColor = (ColorTheme.blue.light, ColorTheme.orange.dark)
        static let dark: ButtonColor = (ColorTheme.blue.dark, ColorTheme.orange.dark)
    }*/
}
