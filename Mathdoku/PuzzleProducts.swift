//
//  PuzzleProducts.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 6/11/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import StoreKit
import RealmSwift

typealias PuzzleProduct = (productIdentifier: String, buysAllowance: Int)
typealias LoadedProduct = (product: SKProduct, title: String, description: String, price: String)

enum PuzzleRefreshMode {
    case purchase
    case weekly
    case error(String)
}

struct PuzzleProducts {
    static let puzzle100: PuzzleProduct = ("com.geissefamily.taylor.puzzle100", 100)
    static let puzzle1000: PuzzleProduct = ("com.geissefamily.taylor.puzzle1000", 1000)
    
    private static let loadedInfo = LoadedInformation()
    
    private class LoadedInformation {
        var loadedPuzzleProducts = Dictionary<String, LoadedProduct>()
        lazy var realm: Realm = {
            do {
                let localRealm = try Realm()
                return localRealm
            } catch (let error) {
                fatalError("Error creating a realm in PuzzleProducts.LoadedInformation:\n\(error)")
            }
        }()
        var refreshMode: PuzzleRefreshMode?
        
        func determineRefreshMode() -> PuzzleRefreshMode {
            if let puzzleAllowance = realm.objects(Allowances.self).filter("allowanceId = ''").first {
                
                if puzzleAllowance.lastPurchaseDate.timeIntervalSince1970 < puzzleAllowance.lastRefreshDate.timeIntervalSince1970 {
                    refreshMode = .weekly
                } else {
                    refreshMode = .purchase
                }
            } else {
                refreshMode = PuzzleRefreshMode.error("Unable to find an allowance for \(AllowanceTypes.puzzle.id())")
            }
            
            return refreshMode!
        }
    }
    
    static func wasAbleToRefreshWeeklyPuzzleAllowance() -> Bool {
        return false
    }
    
    static func getPuzzleRefreshMode() -> PuzzleRefreshMode {
        return loadedInfo.refreshMode ?? loadedInfo.determineRefreshMode()
    }
    
    static func getLoadedPuzzleProductInfo(productId: String) -> LoadedProduct? {
        return loadedInfo.loadedPuzzleProducts[productId]
    }
    
    static func setPuzzleProductInfo(productInfo: LoadedProduct) {
        loadedInfo.loadedPuzzleProducts[productInfo.product.productIdentifier] = productInfo
    }
}
