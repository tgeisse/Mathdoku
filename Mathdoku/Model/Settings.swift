//
//  Settings.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 11/15/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

// Defaults extension for settings variables
extension DefaultsKeys {
    var singleNoteCellSelection: DefaultsKey<Bool> { .init("singleNoteCellSelection", defaultValue: false) }
    var clearNotesAfterGuessEntry: DefaultsKey<Bool> { .init("clearNotesAfterGuessEntry", defaultValue: true) }
    var rotateAfterCellEntry: DefaultsKey<Bool> { .init("rotateAfterCellEntry", defaultValue: false) }
    var highlightSameGuessEntry: DefaultsKey<Bool> { .init("highlightSameGuessEntry", defaultValue: true) }
    var highlightConflictingEntries: DefaultsKey<Bool> { .init("highlightConflictingEntries", defaultValue: true) }
    var fillInGiveMes: DefaultsKey<Bool> { .init("fillInGiveMes", defaultValue: false) }
    var doubleTapToggleNoteMode: DefaultsKey<Bool> { .init("doubleTapToggleNoteMode", defaultValue: true) }
    var dailyRefreshNotice: DefaultsKey<Bool> { .init("dailyRefreshNotice", defaultValue: true) }
    var colorTheme: DefaultsKey<Int> { .init("colorTheme", defaultValue:  0) }
    var enableKeyboardInput: DefaultsKey<Bool> { .init("enableKeyboardInput", defaultValue: true) }
}
