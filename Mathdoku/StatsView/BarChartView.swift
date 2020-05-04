//
//  BarChart.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 4/8/20.
//  Copyright © 2020 Taylor Geisse. All rights reserved.
//

import UIKit

class BarChartView: UIView {
    // primary layer for the graph elements and drawer
    private let graphLayer = CALayer()
    private let drawer = BarChartDrawer()
    
    // bar chart information
    private var barWidth: CGFloat = 10.0
    private var spacing: CGFloat = 2.0
    private let numberBuckets = 20
    
    private var barGraphs: [BarGraphEntry] = [] {
        didSet {
            graphLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
            
            addBorderLines()
            
            for (index, entry) in barGraphs.enumerated() {
                addBar(barEntry: entry, oldEntry: oldValue.safeValue(at: index))
            }
        }
    }
    
    private var calculateBarWidth: CGFloat {
        return (frame.width - (spacing * CGFloat(numberBuckets))) / CGFloat(numberBuckets)
    }
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        initData()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initData()
    }
    
    private func initData() {
        barWidth = calculateBarWidth
        graphLayer.frame = frame
        
        addBorderLines()
        
        // loop through and add new empty BarGraphEntries
        for bucket in 0..<numberBuckets {
            let origin = CGPoint(x: spacing + (barWidth + spacing) * CGFloat(bucket), y: 0)
            let newEntry = BarGraphEntry(origin: origin, barWidth: barWidth, barHeight: 100.5, space: spacing)
            barGraphs.append(newEntry)
        }
    }
    
    // MARK: - Data Processing
    // process inbound data
    func processDataSet(solvedPuzzles: [Double]) {
        for i in 0..<20 {
            barGraphs[i] = BarGraphEntry(origin)
        }
    }
    
    // MARK: - Bar Graph Drawing
    // draw individual bar
    private func addBar(barEntry: BarGraphEntry, oldEntry: BarGraphEntry? = nil) {
        let animated = oldEntry == nil ? false : true
        
        // grab the color
        let barColor = ColorTheme.blue.dark.cgColor
        
        // add the main bar
        graphLayer.addRectangleLayer(frame: barEntry.barFrame, color: barColor, oldFrame: oldEntry?.barFrame, animated: animated)
    }
    
    // add border lines to the graph
    private func addBorderLines() {
        let topLeft = CGPoint(x: 0, y: 0)
        let bottomLeft = CGPoint(x: frame.height, y: 0)
        let bottomRight = CGPoint(x: frame.height, y: frame.width)
        
        let leftBorder = LineSegment(startPoint: topLeft, endPoint: bottomLeft)
        let bottomBorder = LineSegment(startPoint: bottomLeft, endPoint: bottomRight)
        
        graphLayer.addLineLayer(lineSegment: leftBorder, color: UIColor.black.cgColor, width: 2, isDashed: false, animated: false)
        graphLayer.addLineLayer(lineSegment: bottomBorder, color: UIColor.black.cgColor, width: 2, isDashed: false, animated: false)
    }
}
