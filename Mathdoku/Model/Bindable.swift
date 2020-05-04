//
//  Bindable.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 4/11/20.
//  Copyright © 2020 Taylor Geisse. All rights reserved.
//

class Bindable<T> {
    typealias Listener = (T) -> ()
    var listener: Listener?
    
    func bind(_ listener: Listener?) {
        self.listener = listener
    }
    
    func bindAndFire(_ listener: Listener?) {
        bind(listener)
        listener?(value)
    }
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    init(_ v: T) {
        value = v
    }
}
