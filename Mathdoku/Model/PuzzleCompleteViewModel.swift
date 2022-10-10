//
//  PuzzleCompleteViewModel.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 10/3/22.
//  Copyright © 2022 Taylor Geisse. All rights reserved.
//

import Foundation

protocol StartNextPuzzleDelegate: AnyObject {
    func nextPuzzleButtonPress() -> Void
}

class PuzzleCompleteViewModel: ObservableObject {
/*    @Published var puzzleSize: Int
    @Published var time: String
    @Published var bestTime: String
    @Published var isBestTime: Bool */
    
    let puzzleSize: Int
    let time: String
    let timesForSize: [Double]
    let bestTime: String
    let isBestTime: Bool
    weak var startNextPuzzleDelegate: StartNextPuzzleDelegate?
    
    init(puzzleSize: Int, time: String, timesForSize: [Double], bestTime: String, isBestTime: Bool, startNextPuzzleDelegate: StartNextPuzzleDelegate? = nil) {
        self.puzzleSize = puzzleSize
        self.time = time
        self.timesForSize = timesForSize
        self.bestTime = bestTime
        self.isBestTime = isBestTime
        self.startNextPuzzleDelegate = startNextPuzzleDelegate
    }
    
    deinit {
        DebugUtil.print("PuzzleCompleteViewModel has been deallocated")
    }
}
