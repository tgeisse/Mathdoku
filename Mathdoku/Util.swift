//
//  Util.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 6/8/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import Foundation

struct Util {
    static func iterateEnum<T: Hashable>(_: T.Type) -> AnyIterator<T> {
        var i = 0
        return AnyIterator {
            let next = withUnsafeBytes(of: &i) { $0.load(as: T.self) }
            if next.hashValue != i { return nil }
            i += 1
            return next
        }
    }
}
