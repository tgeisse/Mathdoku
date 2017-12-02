//
//  HighlightRequestQueue.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 12/1/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import Foundation

class HighlightRequestQueue {
    private var requests: Dictionary<CellView.GuessAllegiance, Int> = [:]
    fileprivate let highlightRequestQueue = DispatchQueue(
        label: "com.geissefamily.taylor.highlightRequestQueue",
        qos: .default,
        attributes: .concurrent
    )
    
    /// Add a request for the specific Guess Allegiance highlight
    func addRequest(for allegiance: CellView.GuessAllegiance) {
        highlightRequestQueue.async (flags: .barrier) { [weak self] in
            self?.requests[allegiance] = (self?.requests[allegiance] ?? 0) + 1
        }
    }
    
    /// Return the number of requests for the specific Guess Allegiance highlight
    func numberRequests(for allegiance: CellView.GuessAllegiance) -> Int {
        var requestCount = 0
        highlightRequestQueue.sync { [weak self] in
            requestCount = self?.requests[allegiance] ?? 0
        }
        return requestCount
    }
    
    /// Reset the requests for the specified Guess Allegiance
    func clearRequests(for allegiance: CellView.GuessAllegiance) {
        highlightRequestQueue.async (flags: .barrier) { [weak self] in
            self?.requests[allegiance] = 0
        }
    }
}
