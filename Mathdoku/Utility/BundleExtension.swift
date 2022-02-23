//
//  BundleExtension.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 2/22/22.
//  Copyright © 2022 Taylor Geisse. All rights reserved.
//

import Foundation

enum MainBundleInformation: String {
    case version    = "CFBundleShortVersionString"
    case identifier = "CFBundleIdentifier"
    
    var value: Any? { return Bundle.main.infoDictionary?[self.rawValue] }
    var string: String? { return value as? String }
}
