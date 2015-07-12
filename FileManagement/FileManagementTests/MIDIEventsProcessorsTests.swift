//
//  MIDIEventsProcessorsTests.swift
//  FileManagement
//
//  Created by JohnBob on 10/04/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit
import XCTest

class MIDIEventsProcessorsTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testProcessProgramChange() {

        var b: ByteBuffer = ByteBuffer(order: BigEndian(), capacity: 8);

        b.putUInt16(0xC542);
        b.rewind();

        let res = processProgramChange(b);
        XCTAssert(res == [5, 66], "wrong result! got \(res)");
    }

    func testProcessNoteOnEvent() {

        var b: ByteBuffer = ByteBuffer(order: BigEndian(), capacity: 8);

        b.putUInt8(0x92);
        b.putUInt16(0x4264);
        b.rewind();

        let res = processNoteOnEvent(b);
        XCTAssert(res == [2, 66, 100], "wrong result! got \(res)");
    }

    func testProcessNoteOffEvent() {

        var b: ByteBuffer = ByteBuffer(order: BigEndian(), capacity: 8);

        b.putUInt8(0x82);
        b.putUInt16(0x4200);
        b.rewind();

        let res = processNoteOffEvent(b);
        XCTAssert(res == [2, 66, 0], "wrong result! got \(res)");
    }

    func testProcessTempoEvent() {

        var b: ByteBuffer = ByteBuffer(order: BigEndian(), capacity: 8);

        b.putUInt32(0x0307A120);
        b.rewind();

        let res = processTempoEvent(b);
        XCTAssert(res == [120], "wrong result! got \(res)");
    }

    func testProcessTimeSigEvent() {

        var b: ByteBuffer = ByteBuffer(order: BigEndian(), capacity: 20);

        b.putUInt8(0x04);
        b.putUInt32(0x04021808)
        b.rewind();

        let res = processTimeSigEvent(b);
        XCTAssert(res == [4, 4 , 24, 8], "wrong result! got \(res)");
    }

    func testProcessUnkownEvent() {

        var b: ByteBuffer = ByteBuffer(order: BigEndian(), capacity: 15);

        b.putUInt32(0x0307A120);
        b.putUInt32(0x0307A120);
        b.putUInt32(0x0307A120);
        b.putUInt8(0x82);
        b.putUInt16(0x4200);

        b.rewind();

        let res = processUnknownEvent(b);
        XCTAssert(res == [3, 7, 161, 32, 3, 7, 161, 32, 3, 7, 161, 32], "wrong result! got \(res)");
        let res2 = processNoteOffEvent(b);
        XCTAssert(res2 == [2, 66, 0], "wrong result! got \(res2)");
    }
}
