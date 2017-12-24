//
//  PuzzleProducts.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 6/11/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import StoreKit
import RealmSwift

typealias PuzzleProduct = (productIdentifier: String, buysAllowance: Int, disablesAds: Bool)
typealias LoadedProduct = (product: SKProduct, title: String, description: String, price: String)

enum PuzzleRefreshMode {
    case purchase
    case freeUser
    case error(String)
}

struct PuzzleProducts {
    static let puzzle100: PuzzleProduct = ("com.geissefamily.taylor.puzzle100", 100, true)
    static let puzzle1000: PuzzleProduct = ("com.geissefamily.taylor.puzzle1000", 1000, true)
    
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
        var puzzleAllowance: Allowances?
        
        func queryPuzzleAllowance() -> Allowances {
            puzzleAllowance = realm.objects(Allowances.self).filter("allowanceId = '\(AllowanceTypes.puzzle)'").first!
            return puzzleAllowance!
        }
    }
    
    static var userIsFree: Bool {
        switch puzzleRefreshMode {
        case .freeUser: return true
        default: return false
        }
    }
    
    static var userHasPurchased: Bool {
        switch puzzleRefreshMode {
        case .purchase: return true
        default: return false
        }
    }
    
    static var puzzleAllowance: Allowances {
        get {
            return loadedInfo.puzzleAllowance ?? loadedInfo.queryPuzzleAllowance()
        }
    }
    
    static var puzzleRefreshMode: PuzzleRefreshMode {
        if puzzleAllowance.lastPurchaseDate.timeIntervalSince1970 < puzzleAllowance.lastRefreshDate.timeIntervalSince1970 {
            return .freeUser
        } else {
            return .purchase
        }
    }
    
    static var adsEnabled: Bool {
        return !userHasPurchased
    }
    
    static func getLoadedPuzzleProductInfo(productId: String) -> LoadedProduct? {
        return loadedInfo.loadedPuzzleProducts[productId]
    }
    
    static func setPuzzleProductInfo(productInfo: LoadedProduct) {
        loadedInfo.loadedPuzzleProducts[productInfo.product.productIdentifier] = productInfo
    }
}
