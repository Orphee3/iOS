//
//  MIDIPlayerTests.swift
//  Orphee
//
//  Created by John Bobington on 18/12/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import XCTest

@testable import Orphee

class MIDIPlayerTests: XCTestCase {

    let bundle = NSBundle(forClass: MIDIPlayerTests.self)
    let testFile = NSBundle(forClass: MIDIPlayerTests.self).pathForResource("xtreme", ofType: "mid")!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSetupAudioGraph_succeeds() {
        let pl = try! MIDIPlayer(path: testFile)!

        XCTAssertTrue(pl.setupAudioGraph())
        pl.play()
        usleep(UInt32(pl.duration) * 1000 * 1000)
    }
}
