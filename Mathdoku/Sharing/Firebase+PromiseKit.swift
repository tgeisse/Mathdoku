//
//  Firebase+PromiseKit.swift
//  Mathdoku
//
//  Copyright © 2018 Taylor Geisse. All rights reserved.
//

import Firebase
import Foundation
import PromiseKit

extension DatabaseQuery {
    func getValue() -> Promise<DataSnapshot> {
        return wrap { observeSingleEvent(of: .value, with: $0) }
    }
}

extension DatabaseReference {
    func setValue(_ value: Any?) -> Promise<DatabaseReference> {
        return wrap { setValue(value, withCompletionBlock: $0) }
    }

    func transaction(_ block: @escaping (MutableData) throws -> TransactionResult) -> Promise<(Bool, DataSnapshot?)> {
        return Promise { fulfill, reject in
            var blockError: Error?
            runTransactionBlock({
                do {
                    return try block($0)
                } catch {
                    blockError = error
                    return TransactionResult.abort()
                }
            }, andCompletionBlock: { (error, committed, snapshot) in
                if let error = blockError {
                    reject(error)
                } else if let error = error {
                    reject(error)
                } else {
                    fulfill((committed, snapshot))
                }
            })
        }
    }
}
