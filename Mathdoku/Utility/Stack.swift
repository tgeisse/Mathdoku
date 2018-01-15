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
    private var maxSize: Int?
    
    init(maxSize: Int? = nil) {
        self.maxSize = maxSize
    }
    
    mutating func push(_ item: T) {
        if let size = maxSize {
            if items.count >= size {
                items.removeFirst(items.count - size + 1)
            }
        }
        
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
