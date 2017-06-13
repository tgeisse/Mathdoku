//
//  PuzzleProducts.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 6/11/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import StoreKit

typealias PuzzleProduct = (productIdentifier: String, buysAllowance: Int)
typealias LoadedProduct = (product: SKProduct, title: String, description: String, price: String)

struct PuzzleProducts {
    static let puzzle100: PuzzleProduct = ("com.geissefamily.taylor.puzzle100", 100)
    
    static let puzzle1000: PuzzleProduct = ("com.geissefamily.taylor.puzzle1000", 1000)
    
    static var loadedPuzzleProducts = Dictionary<String, LoadedProduct>()
}
