//
//  SharingController.swift
//  Mathdoku
//
//  Copyright © 2018 Taylor Geisse. All rights reserved.
//

import Firebase
import Foundation
import MessageUI
import PromiseKit

private extension String {
    static func random(length: Int) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""

        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(base.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }

        return randomString
    }

    static func fromTimeInterval(_ interval: TimeInterval) -> String {
        let minutes = Int(interval / 60)
        let seconds = Int(interval) - (Int(interval / 60) * 60)

        return String(format: "%0.2d:%0.2d", minutes, seconds)
    }
}

struct Challenge {
    let puzzleID: Int
    let victoryTime: TimeInterval
}

class SharingController {
    enum Error: Swift.Error {
        case deviceIDNotAvailable
        case sendingMessagesUnsupported
        case invalidURL(URL)
        case invalidValue(Any?)
    }

    static let baseURL = URL(string: "https://mathdoku.ch/play/")!
    static let keyLength = 12

    let database: DatabaseReference

    init(databaseReference ref: DatabaseReference) {
        self.database = ref
    }

    func url(for challenge: Challenge) -> Promise<URL> {
        guard let deviceID = UIDevice().identifierForVendor?.uuidString else {
            return Promise(error: Error.deviceIDNotAvailable)
        }

        let key = String.random(length: SharingController.keyLength)

        let value: [String: Any] = [
            "puzzleID": challenge.puzzleID,
            "victoryTime": challenge.victoryTime,
            "createdAt": Date().timeIntervalSince1970,
            "senderDevice": deviceID,
        ]

        return database.child("challenges").child(key).setValue(value).then { _ in
            return SharingController.baseURL.appendingPathComponent(key)
        }
    }

    func message(for challenge: Challenge) -> Promise<String> {
        return url(for: challenge).then { url -> String in
            let timeString = String.fromTimeInterval(challenge.victoryTime)
            return "I completed this Mathdoku puzzle in \(timeString)! Try this puzzle and get 30 more free: \(url)"
        }
    }

    func presentComposeViewController(for challenge: Challenge, inParentViewController parentViewController: UIViewController) -> Promise<Void> {
        if !MFMessageComposeViewController.canSendText() {
            return Promise(error: Error.sendingMessagesUnsupported)
        }

        return message(for: challenge).then { message -> Void in
            let composer = MFMessageComposeViewController()
            composer.body = message
            parentViewController.present(composer, animated: true, completion: nil)
        }
    }

    func challenge(from url: URL, consume: Bool = true) -> Promise<Challenge> {
        if !url.absoluteString.starts(with: SharingController.baseURL.absoluteString) {
            return Promise(error: Error.invalidURL(url))
        }

        let key = url.lastPathComponent

        return database.child("challenges").child(key).transaction { data -> TransactionResult in
            guard var value = data.value as? [String: Any] else {
                throw Error.invalidValue(data.value)
            }

            if consume && value["consumed"] as? Bool != true {
                guard let deviceID = UIDevice().identifierForVendor?.uuidString else {
                    throw Error.deviceIDNotAvailable
                }

                // mark as consumed
                value["consumed"] = true
                value["consumedAt"] = Date().timeIntervalSince1970
                value["recipientDevice"] = deviceID

                data.value = value
            }

            return TransactionResult.success(withValue: data)

        }.then { _, snapshot -> Challenge in
            // extract challenge parameters from value
            guard let value = snapshot!.value as? [String: Any],
                let puzzleID = value["puzzleID"] as? Int,
                let victoryTime = value["victoryTime"] as? TimeInterval else {
                    throw Error.invalidValue(snapshot!.value)
            }

            return Challenge(puzzleID: puzzleID, victoryTime: victoryTime)
        }
    }

    func countMyConsumedChallenges() -> Promise<Int> {
        guard let deviceID = UIDevice().identifierForVendor?.uuidString else {
            return Promise(error: Error.deviceIDNotAvailable)
        }

        // count consumed challenges where senderDevice is this device
        return database.child("challenges").queryOrdered(byChild: "senderDevice").queryEqual(toValue: deviceID).getValue().then { snapshot -> Int in
            var count = 0
            for challenge in snapshot.children {
                if (challenge as? [String: Any])?["consumed"] as? Bool == true {
                    count += 1
                }
            }
            return count
        }
    }
}
