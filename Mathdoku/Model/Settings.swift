//
//  Settings.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 11/15/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

enum LongPressDuration: String, CaseIterable, DefaultsSerializable {
    case normal
    case long
    case short
    
    var duration: TimeInterval {
        switch self {
        case .normal:   return 0.5
        case .long:     return 0.75
        case .short:    return 0.25
        }
    }
}

// Defaults extension for settings variables
extension DefaultsKeys {
    var singleNoteCellSelection: DefaultsKey<Bool> { .init("singleNoteCellSelection", defaultValue: false) }
    var clearNotesAfterGuessEntry: DefaultsKey<Bool> { .init("clearNotesAfterGuessEntry", defaultValue: true) }
    var rotateAfterCellEntry: DefaultsKey<Bool> { .init("rotateAfterCellEntry", defaultValue: true) }
    var highlightSameGuessEntry: DefaultsKey<Bool> { .init("highlightSameGuessEntry", defaultValue: true) }
    var highlightConflictingEntries: DefaultsKey<Bool> { .init("highlightConflictingEntries", defaultValue: true) }
    var fillInGiveMes: DefaultsKey<Bool> { .init("fillInGiveMes", defaultValue: true) }
    var doubleTapToggleNoteMode: DefaultsKey<Bool> { .init("doubleTapToggleNoteMode", defaultValue: true) }
    var dailyRefreshNotice: DefaultsKey<Bool> { .init("dailyRefreshNotice", defaultValue: true) }
    var colorTheme: DefaultsKey<Int> { .init("colorTheme", defaultValue:  0) }
    var enableKeyboardInput: DefaultsKey<Bool> { .init("enableKeyboardInput", defaultValue: true) }
    var drawFriendlyBorder: DefaultsKey<Bool> { .init("drawFriendlyBorder", defaultValue: true) }
    var enableStartCountdownTimer: DefaultsKey<Bool> { .init("enableStartCountdownTimer", defaultValue: true) }
    var longPressTogglesToNoteEntry: DefaultsKey<Bool> { .init("longPressTogglesToNoteEntry", defaultValue: true) }
    var longPressDuration: DefaultsKey<LongPressDuration> { .init("longPressDuration", defaultValue: .normal) }
}
