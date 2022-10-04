//
//  PuzzleCompleteViewModel.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 10/3/22.
//  Copyright © 2022 Taylor Geisse. All rights reserved.
//

import Foundation

protocol StartNextPuzzleDelegate {
    func nextPuzzleButtonPress() -> Void
}

class PuzzleCompleteViewModel: ObservableObject {
    let puzzleSize: Int
    let time: String
    let bestTime: String
    let isBestTime: Bool
    var startNextPuzzleDelegate: StartNextPuzzleDelegate?
    
    init(puzzleSize: Int, time: String, bestTime: String, isBestTime: Bool, startNextPuzzleDelegate: StartNextPuzzleDelegate? = nil) {
        self.puzzleSize = puzzleSize
        self.time = time
        self.bestTime = bestTime
        self.isBestTime = isBestTime
        self.startNextPuzzleDelegate = startNextPuzzleDelegate
    }
    
    deinit {
        DebugUtil.print("PuzzleCompleteViewModel has been destroyed")
    }
}
