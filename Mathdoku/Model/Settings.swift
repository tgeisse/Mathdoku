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
    var singleNoteCellSelection: DefaultsKey<Bool> { return .init("singleNoteCellSelection", defaultValue: false) }
    var clearNotesAfterGuessEntry: DefaultsKey<Bool> { return .init("clearNotesAfterGuessEntry", defaultValue: true) }
    var rotateAfterCellEntry: DefaultsKey<Bool> { return .init("rotateAfterCellEntry", defaultValue: false) }
    var highlightSameGuessEntry: DefaultsKey<Bool> { return .init("highlightSameGuessEntry", defaultValue: true) }
    var highlightConflictingEntries: DefaultsKey<Bool> { return .init("highlightConflictingEntries", defaultValue: true) }
    var fillInGiveMes: DefaultsKey<Bool> { return .init("fillInGiveMes", defaultValue: false) }
    var doubleTapToggleNoteMode: DefaultsKey<Bool> { return .init("doubleTapToggleNoteMode", defaultValue: true) }
    var dailyRefreshNotice: DefaultsKey<Bool> { return .init("dailyRefreshNotice", defaultValue: true) }
    var colorTheme: DefaultsKey<Int> { return .init("colorTheme", defaultValue:  0) }
}
