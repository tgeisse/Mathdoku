//
//  Version.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 6/3/24.
//  Copyright © 2024 Taylor Geisse. All rights reserved.
//

import Foundation

struct Version: Comparable, Equatable, CustomStringConvertible {
    private let major: Int
    private let minor: Int
    private let patch: Int
    
    init?(versionString: String) {
        let stringComps = versionString.components(separatedBy: ".")
        if stringComps.isEmpty { return nil }
        
        var nums: [Int] = []
        
        for comp in stringComps[..<min(stringComps.count, 3)] {
            guard let intValue = Int(comp) else { return nil }
            nums.append(intValue)
        }
        
        if nums.count == 1 {
            major = nums[0]
            minor = 0
            patch = 0
        } else if nums.count == 2 {
            major = nums[0]
            minor = nums[1]
            patch = 0
        } else {
            major = nums[0]
            minor = nums[1]
            patch = nums[2]
        }
    }
    
    init(_ major: Int, _ minor: Int, _ patch: Int = 0) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }
    
    static func < (lhs: Version, rhs: Version) -> Bool {
        if lhs.major < rhs.major { return true }
        if lhs.major > rhs.major { return false }
        
        if lhs.minor < rhs.minor { return true }
        if lhs.minor > rhs.minor { return false }
        
        if lhs.patch < rhs.patch { return true }
        return false
    }
    
    static func == (lhs: Version, rhs: Version) -> Bool {
        lhs.major == rhs.major &&
        lhs.minor == rhs.minor &&
        lhs.patch == rhs.patch
    }
    
    var description: String { "\(major).\(minor).\(patch)" }
}
