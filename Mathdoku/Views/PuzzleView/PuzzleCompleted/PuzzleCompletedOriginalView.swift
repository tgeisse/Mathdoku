//
//  PuzzleCompletedOriginalView.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 10/4/22.
//  Copyright © 2022 Taylor Geisse. All rights reserved.
//

import SwiftUI

struct PuzzleCompletedOriginalView: View {
    @EnvironmentObject var viewModel: PuzzleCompleteViewModel
    @StateObject private var colorTheme = ColorTheme.sharedInstance
    
    var body: some View {
        ZStack(alignment: .center) {
            if #available(iOS 14.0, *) {
                colorTheme.background.suiColor.ignoresSafeArea()
            } else {
                colorTheme.background.suiColor.edgesIgnoringSafeArea(.all)
            }
            
            VStack(alignment: .center) {
                Text("Puzzle Complete!")
                    .font(.custom("Verdana Bold", size: 30.0))
                    .foregroundColor(ColorTheme.sharedInstance.puzzleCompleteAndCountdown.suiColor)
                
                HStack(alignment: .center) {
                    VStack(spacing: 5) {
                        VStack {
                            Text("Your Time")
                                .font(.custom("Verdana", size: 17.0))
                                .foregroundColor(ColorTheme.sharedInstance.fonts.suiColor)
                            Text(viewModel.time)
                                .font(.custom("Verdana", size: 17.0))
                                .foregroundColor(ColorTheme.sharedInstance.fonts.suiColor)
                        }
                        
                        VStack {
                            Text("Best Size \(viewModel.puzzleSize) Time")
                                .font(.custom("Verdana", size: 14.0))
                                .foregroundColor(ColorTheme.sharedInstance.fonts.suiColor)
                            if viewModel.isBestTime {
                                Text("New Best Time!")
                                    .font(.custom("Verdana", size: 14.0))
                                    .foregroundColor(ColorTheme.sharedInstance.positiveTextLabel.suiColor)
                            } else {
                                Text(viewModel.bestTime)
                                    .font(.custom("Verdana", size: 14.0))
                                    .foregroundColor(ColorTheme.sharedInstance.fonts.suiColor)
                            }
                        }
                    }
                    
                    Spacer()
                        .frame(maxWidth: 45)
                    
                    if viewModel.startNextPuzzleDelegate != nil {
                        Button("Next Puzzle") {
                            viewModel.startNextPuzzleDelegate?.nextPuzzleButtonPress()
                        }
                        .font(.custom("Verdana", size: 20))
                    }
                }
            }
        }
    }
}

struct PuzzleCompletedOriginalView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PuzzleCompletedOriginalView()
                .environmentObject(PuzzleCompleteViewModel(puzzleSize: 6, time: "00:01:30", timesForSize: [90.0, 60.0, 180.0], bestTime: "00:01:14", isBestTime: false))
            PuzzleCompletedOriginalView()
                .environmentObject(PuzzleCompleteViewModel(puzzleSize: 6, time: "00:01:12", timesForSize: [90.0], bestTime: "New Best Time!", isBestTime: true))
        }
    }
}
