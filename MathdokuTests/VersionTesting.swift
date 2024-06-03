//
//  VersionTesting.swift
//  MathdokuTests
//
//  Created by Taylor Geisse on 6/3/24.
//  Copyright © 2024 Taylor Geisse. All rights reserved.
//

import XCTest

final class VersionTesting: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testEqual() throws {
        let v1 = Version(2,0,0)
        let v2 = Version(2,0,0)
        XCTAssertEqual(v1, v2)
        
        XCTAssertEqual(Version(2,1,2),
                       Version(2,1,2))
        
        XCTAssertEqual(Version(2,1,2),
                       Version(versionString: "2.1.2"))
        
        XCTAssertEqual(Version(2,1,2),
                       Version(versionString: "2.1.2.4.5"))
        
        XCTAssertEqual(Version(2,1,2),
                       Version(versionString: "2.1.2.4.x.65"))
    }
    
    func testNotEqualMajor() throws {
        let v1 = Version(2,0,0)
        let v2 = Version(1,0,0)
        XCTAssertFalse(v1 == v2)
    }
    
    func testNotEqualMinor() throws {
        let v1 = Version(2,0,0)
        let v2 = Version(2,1,0)
        XCTAssertFalse(v1 == v2)
    }
    
    func testNotEqualPatch() throws {
        let v1 = Version(2,0,0)
        let v2 = Version(2,0,1)
        XCTAssertFalse(v1 == v2)
    }
    
    func testFailedParsing() throws {
        let v1 = Version(versionString: "")
        XCTAssertNil(v1)
        
        let v2 = Version(versionString: "x")
        XCTAssertNil(v2)
        
        let v3 = Version(versionString: "3.x")
        XCTAssertNil(v3)
    }
    
    func testSuccessfulParsing() throws {
        let v1 = Version(versionString: "2.0.0")
        XCTAssertEqual(Version(2,0,0), v1)
        
        let v2 = Version(versionString: "2.1.3")
        XCTAssertEqual(Version(2,1,3), v2)
        
        let v3 = Version(versionString: "2.1")
        XCTAssertEqual(Version(2,1), v3)
        XCTAssertEqual(Version(2,1,0), v3)
        
        let v4 = Version(versionString: "2.1.2.x")
        XCTAssertNotNil(v4)
    }
    
    func testLessThan() throws {
        let newVersion = Version(3,2,4)
        
        XCTAssertTrue(Version(2,0,0) < newVersion)
        XCTAssertTrue(Version(2,2,0) < newVersion)
        XCTAssertTrue(Version(2,2,4) < newVersion)
        XCTAssertTrue(Version(3,0,0) < newVersion)
        XCTAssertTrue(Version(3,2,0) < newVersion)
        XCTAssertTrue(Version(3,2,3) < newVersion)
        XCTAssertTrue(Version(3,0,4) < newVersion)
        XCTAssertTrue(Version(3,0,6) < newVersion)
        XCTAssertTrue(Version(2,10,0) < newVersion)
        XCTAssertTrue(Version(2,10,3) < newVersion)
        XCTAssertTrue(Version(2,10,6) < newVersion)
        XCTAssertTrue(Version(2,2,4) < newVersion)
        XCTAssertTrue(Version(2,1,4) < newVersion)
    }
    
    func testGreaterThan() throws {
        let oldVersion = Version(3,2,4)
        
        XCTAssertTrue(oldVersion < Version(4,0,0))
        XCTAssertTrue(oldVersion < Version(3,2,5))
        XCTAssertTrue(oldVersion < Version(3,3,0))
        XCTAssertTrue(oldVersion < Version(3,3,4))
        XCTAssertTrue(oldVersion < Version(4,2,4))
        XCTAssertTrue(oldVersion < Version(4,1,4))
        XCTAssertTrue(oldVersion < Version(4,4,4))
        XCTAssertTrue(oldVersion < Version(4,1,5))
        XCTAssertTrue(oldVersion < Version(4,1,2))
        XCTAssertTrue(oldVersion < Version(4,2,3))
        XCTAssertTrue(oldVersion < Version(4,2,5))
    }
}
