//
//  ChartPuzzleTimes.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 10/10/22.
//  Copyright © 2022 Taylor Geisse. All rights reserved.
//

import SwiftUI

struct ChartTimeItem {
    let puzzleSize: Int
    let time: Double
    let timeBucket: String
    
    init(puzzleSize: Int, time: Double) {
        self.puzzleSize = puzzleSize
        self.time = time
        self.timeBucket = (time - time.truncatingRemainder(dividingBy: 10.0)).convertToTimeString
    }
}

struct ChartTimeBuckets {
    let timeBucket: String
    let count: Int
}

@available(iOS 16, *)
struct ChartPuzzleTimes: View {
    var timeItems: [ChartTimeItem]
/*    var times: [Double] { didSet { newTimeProcessing() }}
    @State private var sortedTimes: [Double] = []
    private let numberSecondsPerBucket: Double = 10
    private let numberOfBuckets = 10
    private var timeBuckets: [Range<Double>] = [] */
    
    /*
    mutating private func newTimeProcessing() {
        // store times as sorted
        sortedTimes = times.sorted()
        
        // create time buckets
        let startTime: Double
        if let minTime = sortedTimes.first {
            startTime = minTime
        } else {
            startTime = 0.0
        }
        
        let lastTime: Double
        if let maxTime = sortedTimes.last {
            lastTime = maxTime
        } else {
            lastTime = startTime
        }
        
        var newBuckets = [Range<Double>]()
        for bucket in 0..<max(numberOfBuckets, Int(lastTime - startTime / numberSecondsPerBucket) + 1) {
            newBuckets.append(startTime..<(numberSecondsPerBucket * Double(bucket + 1)))
        }
        timeBuckets = newBuckets
    } */
    

    var body: some View {
        Text("Hello World")
        /*
        Chart(timeItems) {
            
        }*/
    }
}

@available(iOS 16, *)
struct ChartPuzzleTimes_Previews: PreviewProvider {
    static var previews: some View {
        ChartPuzzleTimes(timeItems: [
            ChartTimeItem(puzzleSize: 6, time: 90.0),
            ChartTimeItem(puzzleSize: 6, time: 84.0),
            ChartTimeItem(puzzleSize: 6, time: 89.0),
            ChartTimeItem(puzzleSize: 6, time: 95.0),
            ChartTimeItem(puzzleSize: 6, time: 99.999),
            ChartTimeItem(puzzleSize: 6, time: 102.0)
        ])
    }
}
