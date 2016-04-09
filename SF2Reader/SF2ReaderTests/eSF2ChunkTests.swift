//
//  eSF2ChunkTests.swift
//  SF2Reader
//
//  Created by John Bobington on 10/01/2016.
//  Copyright (c) 2016 ___ORPHEE___. All rights reserved.
//

import XCTest
@testable import SF2Reader

class eSF2ChunkTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInit_returns__expectedCase() {
        XCTAssertEqual(eSF2ChunkID(rawValue: "RIFF"), eSF2ChunkID.RIFF)
        XCTAssertEqual(eSF2ChunkID(rawValue: "toto"), eSF2ChunkID.UNKNOWN)
    }

}
