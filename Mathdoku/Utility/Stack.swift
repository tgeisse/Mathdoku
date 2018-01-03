//
//  Stack.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 5/25/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import Foundation

struct Stack<T> {
    fileprivate var items = [T]()
    
    mutating func push(_ item: T) {
        items.append(item)
    }
    
    mutating func pop() -> T? {
        return items.popLast()
    }
    
    mutating func popAll() -> [T] {
        let returnVal = items
        items.removeAll()
        return returnVal
    }
    
    mutating func removeAll() {
        items.removeAll()
    }
    
    var peek: T? {
        return items.last
    }
    
    var isEmpty: Bool {
        return items.isEmpty
    }
    
    var count: Int {
        return items.count
    }

}
