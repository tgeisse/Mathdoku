//
//  AppKeys.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 1/11/18.
//  Copyright © 2018 Taylor Geisse. All rights reserved.
//

import Foundation

enum AppKeys {
    case adMobAppId
    case adMobPuzzleBannerAdId
    
    var key: String {
        switch self {
        case .adMobAppId: return "ca-app-pub-6013095233601848~7942243511"
        case .adMobPuzzleBannerAdId:
            #if DEBUG
                // test ads id when building for debug mode
                return "ca-app-pub-3940256099942544/2934735716"
            #else
                // real ads id for releases
                return "ca-app-pub-6013095233601848/5094263489"
            #endif
        }
    }
}
