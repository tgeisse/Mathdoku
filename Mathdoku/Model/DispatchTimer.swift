//
//  DispatchTimer.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 1/17/18.
//  Copyright © 2018 Taylor Geisse. All rights reserved.
//

import Foundation

/// DispatchTimer mimics the API of DispatchSourceTimer but in a way that prevents
/// crashes that occur from calling resume multiple times on a timer that is
/// already resumed as noted by https://github.com/SiftScience/sift-ios/issues/52
class DispatchTimer {
    
    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource(queue: DispatchQueue(label: "\(AppSecrets.domainRoot).dispatchTimer"))
        t.schedule(deadline: .now(), repeating: precision)
        t.setEventHandler(handler: { [weak self] in
            self?.eventHandler?()
        })
        return t
    }()
    
    var eventHandler: (() -> Void)?
    private var precision: Double
    
    private enum State {
        case suspended
        case resumed
    }
    
    private var state: State = .suspended
    
    init(precision: Double = 0.1) {
        self.precision = precision
    }
    
    deinit {
        timer.setEventHandler {}
        timer.cancel()
        /*
         If the timer is suspended, calling cancel without resuming
         triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
         */
        resume()
        eventHandler = nil
    }
    
    func resume() {
        if state == .resumed {
            return
        }
        state = .resumed
        timer.resume()
    }
    
    func suspend() {
        if state == .suspended {
            return
        }
        state = .suspended
        timer.suspend()
    }
}
