//
//  PuzzleAllowance.swift
//  Mathdoku
//
//  Created by Taylor Geisse on 6/5/17.
//  Copyright © 2017 Taylor Geisse. All rights reserved.
//

import Foundation
import RealmSwift

public enum AllowanceTypes: CustomStringConvertible {
    case puzzle
    
    var initialAllowance: Int {
        switch self {
        case .puzzle: return 10
        }
    }
    
    var refreshAllowance: Int {
        switch self {
        case .puzzle: return 3
        }
    }
    
    var maxRefreshGrants: Int {
        switch self {
        case .puzzle: return 4
        }
    }
    
    public var description: String {
        switch self {
        case .puzzle: return "puzzle"
        }
    }
    
    func infiniteAllowance() -> Int { return -1 }
}

class Allowances: Object {
    @objc dynamic var allowanceId = ""
    @objc dynamic var allowance = 0
    @objc dynamic var lastPurchaseDate = NSDate(timeIntervalSince1970: 1)
    @objc dynamic var lastRefreshDate = NSDate(timeIntervalSince1970: 1)
    
    override static func primaryKey() -> String? {
        return "allowanceId"
    }
    
    func incrementAllowance(to: Int, withRealm: Realm? = nil) {
        incrementAllowance(by: to - self.allowance, withRealm: withRealm)
    }
    
    func incrementAllowance(by incrementBy: Int, withRealm: Realm? = nil) {
        do {
            let realm = try withRealm ?? Realm()
            
            try realm.write {
                allowance = allowance + incrementBy
                lastRefreshDate = NSDate()
            }
        } catch let error {
            CrashWrapper.notifyError(error)
            fatalError("Error incrementing allowance '\(allowanceId)':\n\(error)")
        }
    }
    
    func decrementAllowance(by decrementBy: Int, withRealm: Realm? = nil) {
        do {
            let realm = try withRealm ?? Realm()
            
            try realm.write {
                allowance = allowance - decrementBy
            }
        } catch let error {
            CrashWrapper.notifyError(error)
            fatalError("Error decrementing allowance '\(allowanceId)':\n\(error)")
        }
    }
    
    func playerHasPuzzleAllowance() -> Bool {
        return allowance > 0
    }
}
