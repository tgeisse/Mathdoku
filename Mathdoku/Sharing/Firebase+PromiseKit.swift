//
//  Firebase+PromiseKit.swift
//  Mathdoku
//
//  Copyright © 2018 Taylor Geisse. All rights reserved.
//

import Firebase
import Foundation
import PromiseKit

private let timeout: TimeInterval = 10.0

extension DatabaseQuery {
    enum AsyncError: Error {
        case timedOut
    }

    func getValue() -> Promise<DataSnapshot> {
        return Promise { fulfill, reject in
            var fulfilled = false
            observeSingleEvent(of: .value) {
                fulfill($0)
                fulfilled = true
            }
            after(seconds: timeout).then { () -> () in
                if !fulfilled {
                    reject(AsyncError.timedOut)
                }
            }
        }
    }

    func observeValue() -> Promise<() -> ()> {
        var handle: UInt = 0
        return Promise<UInt> { fulfill, reject in
            var fulfilled = false
            handle = observe(.value) { _ in
                fulfill(handle)
                fulfilled = true
            }
            after(seconds: timeout).then { () -> () in
                if !fulfilled {
                    reject(AsyncError.timedOut)
                }
            }
        }.then { snapshot -> () -> () in
            return { self.removeObserver(withHandle: handle) }
        }
    }
}

extension DatabaseReference {
    func setValue(_ value: Any?) -> Promise<DatabaseReference> {
        return wrap { setValue(value, withCompletionBlock: $0) }
    }

    func transaction(withLocalEvents: Bool = false, _ block: @escaping (MutableData) throws -> TransactionResult) -> Promise<(Bool, DataSnapshot?)> {
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
            }, withLocalEvents: withLocalEvents)
        }
    }
}
