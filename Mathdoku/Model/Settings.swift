//
//  Settings.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 11/15/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import Foundation

// Defaults extension for settings variables
extension DefaultsKeys {
    static let singleNoteCellSelection = DefaultsKey<Bool>("singleNoteCellSelection")
    static let rotateAfterCellEntry = DefaultsKey<Bool>("rotateAfterCellEntry")
}

struct Settings {
    static func initialize() {
        if !Defaults.hasKey(.singleNoteCellSelection) {
            Defaults[.singleNoteCellSelection] = false
        }
        
        if !Defaults.hasKey(.rotateAfterCellEntry) {
            Defaults[.rotateAfterCellEntry] = false
        }
    }
}
