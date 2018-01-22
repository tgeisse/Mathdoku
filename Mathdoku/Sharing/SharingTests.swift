//
//  SharingTests.swift
//  MathdokuTests
//
//  Copyright © 2018 Taylor Geisse. All rights reserved.
//

import Firebase
import PromiseKit
import XCTest

class SharingTests: XCTestCase {
    var controller: SharingController!

    override func setUp() {
        super.setUp()
        controller = SharingController(databaseReference: Database.database().reference())
    }

    override func tearDown() {
        controller = nil
        super.tearDown()
    }

    func testCreateAndConsumeChallenge() {
        let done = expectation(description: "reach end of promise chain")
        var count = 0

        // 1. get initial count of challenges issued by this device and consumed by others
        _ = controller.countMyConsumedChallenges().then { c -> Promise<URL> in
            count = c

            // 2. create a challenge and store it in firebase, resulting in a challenge url
            let challenge = Challenge(puzzleID: 1, victoryTime: 1)
            return self.controller.url(for: challenge)

        }.then { url -> Promise<Challenge> in
            print("URL: \(url)")

            // 3. use the url to look up the challenge in firebase and mark it as consumed
            return self.controller.challenge(from: url)

        }.then { challenge -> Promise<Int> in
            print("Challenge: \(challenge)")

            // 4. count our consumed challenges again
            return self.controller.countMyConsumedChallenges()

        }.then { c -> Void in

            // 5. check that the count increased by 1
            XCTAssertEqual(c, count + 1)
            done.fulfill()

        }.catch { error in
            XCTFail(error.localizedDescription)
        }

        waitForExpectations(timeout: 10, handler: nil)
    }
}
