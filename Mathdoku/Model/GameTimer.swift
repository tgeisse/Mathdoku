//
//  Timer.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 4/15/18.
//  Copyright © 2018 Taylor Geisse. All rights reserved.
//

import Foundation

class GameTimer {
    var runningTime: Double {
        if state == .running {
            return timeSinceStarting + accumulatedTime
        } else {
            return accumulatedTime
        }
    }
    
    private var timeSinceStarting: Double {
        let now = Date()
        return now.timeIntervalSince(currentStartingTime ?? now)
    }
    
    private var accumulatedTime = 0.0
    private var currentStartingTime: Date? = nil
    private var updateClosure: () -> () = {}
    private var timer: Timer? = nil
    private var state = State.stopped
    
    enum State {
        case stopped
        case running
        case paused
    }
    
    func start() {
        if state == .running { return }
        
        currentStartingTime = Date()
        
        let timeToSecond = runningTime.truncatingRemainder(dividingBy: 1)
        
        if timeToSecond == 0 { startRepeatingTimer() }
        else {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0 - timeToSecond, repeats: false) { [weak self] _ in
                self?.updateClosure()
                self?.startRepeatingTimer()
            }
        }
        
        state = .running
    }
    
    private func startRepeatingTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateClosure()
        }
        state = .running
    }
    
    func pause() {
        if state != .running { return }
    
        timer?.invalidate()
        accumulatedTime += timeSinceStarting
        state = .paused
    }
    
    func stop() {
        if state == .stopped { return }
        
        timer?.invalidate()
        accumulatedTime += timeSinceStarting
        state = .stopped
    }
    
    func setUpdateCallback(to: @escaping () -> ()) {
        updateClosure = to
    }
    
    func adjustAccumulatedTime(to: Double) {
        accumulatedTime = to
    }
}
