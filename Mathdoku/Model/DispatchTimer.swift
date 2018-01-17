//
//  DispatchTimer.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 1/16/18.
//  Copyright © 2018 Taylor Geisse. All rights reserved.
//

import Foundation

class DispatchTimer {
    private enum State {
        case stopped
        case running
        case paused
    }
    private var state: State = .stopped
    private var timer: DispatchSourceTimer? = nil
    private var eventHandler: ((Double) -> ())? = nil
    private var precision: Double
    private let queue = DispatchQueue(label: "\(AppSecrets.domainRoot).dispatchTimerQueue", attributes: .concurrent)
    
    init(precision: Double = 0.1) {
        self.precision = precision
    }
    
    func registerEventHandler(_ closure: @escaping (Double) -> ()) {
        eventHandler = closure
    }
    
    func start() {
        if state != .paused {
            timer?.cancel()
            timer = DispatchSource.makeTimerSource(queue: queue)
            timer?.schedule(deadline: .now(), repeating: precision)
            timer?.setEventHandler() { [weak self] in
                DebugUtil.print("DispatchTimer event triggered")
                if let strongSelf = self {
                    strongSelf.eventHandler?(strongSelf.precision)
                }
            }
        }
        
        timer?.resume()
        state = .running
    }
    
    func pause() {
        timer?.suspend()
        state = .paused
    }
    
    func stop() {
        timer?.cancel()
        state = .stopped
    }
}
