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
        if !isStopped {
            return timeSinceStarting + accumulatedTime
        } else {
            return accumulatedTime
        }
    }
    
    private var timeSinceStarting: Double {
        return Date().timeIntervalSince(currentStartingTime)
    }
    
    private var accumulatedTime = 0.0
    private var currentStartingTime = Date()
    private var updateClosure: () -> () = {}
    private var timer: Timer? = nil
    private var isStopped = true
    
    func start() {
        if !isStopped { return }
        
        currentStartingTime = Date()
        
        let timeToSecond = runningTime.truncatingRemainder(dividingBy: 1)
        
        if timeToSecond == 0 { startRepeatingTimer() }
        else {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0 - timeToSecond, repeats: false) { [weak self] _ in
                self?.updateClosure()
                self?.startRepeatingTimer()
            }
        }
        
        isStopped = false
    }
    
    private func startRepeatingTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateClosure()
        }
        isStopped = false // redundant in most cases, but is good for safe measures
    }
    
    func stop() {
        if isStopped { return }
        
        timer?.invalidate()
        accumulatedTime += timeSinceStarting
        isStopped = true
    }
    
    func reset() {
        stop()
        adjustAccumulatedTime(to: 0.0)
    }
    
    func setUpdateCallback(to: @escaping () -> ()) {
        updateClosure = to
    }
    
    func adjustAccumulatedTime(to: Double) {
        accumulatedTime = to
    }
    
    deinit {
        timer?.invalidate()
    }
}
