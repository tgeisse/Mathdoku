//
//  Stack.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 5/25/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import Foundation

struct Stack<T> {
    private var items = [T]()
    
    mutating func push(_ item: T) {
        items.append(item)
    }
    
    mutating func pop() -> T {
        return items.removeLast()
    }
    
    mutating func popAll() -> [T] {
        let stackCopy = items
        items = []
        return stackCopy
    }
    
    var peek: T? {
        return items.last
    }
}
