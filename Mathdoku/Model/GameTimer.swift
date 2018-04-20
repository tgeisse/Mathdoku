//
//  Timer.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 4/15/18.
//  Copyright © 2018 Taylor Geisse. All rights reserved.
//

import Foundation

class GameTimer {
    var runningTime = 0.0
    private var currentStartingTime: Date? = nil
    private var updateClosure: () -> () = {}
    private let timer: Timer? = nil
    private var state = State.stopped
    
    enum State {
        case stopped
        case running
        case paused
    }
    
    func start() {
        if state == .running { return }
        
        currentStartingTime = Date()
        
    }
    
    func pause() {
        if state != .running { return }
        timer?.invalidate()
        runningTime += (Date() - currentStartingTime)
        state = .paused
    }
    
    func stop() {
        if state == .stopped { return }
        timer?.invalidate()
        runningTime += (Date() - currentStartingTime)
        state = .stopped
    }
}
