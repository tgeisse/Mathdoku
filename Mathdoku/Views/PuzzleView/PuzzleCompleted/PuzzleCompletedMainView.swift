//
//  PuzzleCompletedMainView.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 10/3/22.
//  Copyright © 2022 Taylor Geisse. All rights reserved.
//

import SwiftUI

struct PuzzleCompletedMainView: View {
    @State private var showOriginal = false
    
    var body: some View {
        ZStack {
            if showOriginal {
                PuzzleCompletedOriginalView()
            } else {
                Text("New View")
            }
            
            Button("Switch to \(showOriginal ? "new" : "old")") {
                showOriginal.toggle()
            }
            .font(.system(size: 8))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding()
        }
    }
}

struct PuzzleCompletedMainView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PuzzleCompletedMainView()
                .environmentObject(PuzzleCompleteViewModel(puzzleSize: 6, time: "00:01:30", timesForSize: [90.0], bestTime: "00:01:14", isBestTime: false))
            PuzzleCompletedMainView()
                .environmentObject(PuzzleCompleteViewModel(puzzleSize: 6, time: "00:01:30", timesForSize: [90.0, 60.0, 180.0], bestTime: "00:01:14", isBestTime: false))
        }
    }
}
