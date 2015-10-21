//
//  EventsProcessorsTests.swift
//  FileManagement
//
//  Created by JohnBob on 09/09/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import UIKit
import XCTest

@testable import MIDIToolbox


extension processingError: Equatable {}

public func ==(lhs: processingError, rhs: processingError) -> Bool {
    switch (lhs, rhs) {
    case (.dataIsInvalidLengthForEventType(_, _, _), .dataIsInvalidLengthForEventType(_, _, _)):
        return true
    case (.readBeyondLimit(_, _, _), .readBeyondLimit(_, _, _)):
        return true
    default:
        return false
    }
}

/** EventsProcessorsTests Class

*/
class EventsProcessorsTests : XCTestCase {

    var buffer: ByteBuffer!


    // MARK: - Setup
    override func setUp() {
        super.setUp()
        // Put Setup code here. This method is called before the invocation of each test method in the class.

        buffer = ByteBuffer(order: BigEndian(), capacity: 8)
        buffer.putUInt8([0,0,0,0,0,0,0,0]);
        buffer.rewind();
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    // MARK: Tests

    // MARK: processTimeSigEvent()
    func testProcessTimeSigEvent_throws__when_dataLength_isInferiorTo_0x04() {
        buffer.putUInt8(0x03);
        buffer.rewind();

        XCTAssertThrowsSpecific(try processTimeSigEvent(buffer), exception: processingError.dataIsInvalidLengthForEventType(eMidiEventType.timeSignature, length: 0, kOrpheeDebug_metaEventProc_timeSigDataInvalidLength))
    }

    func testProcessTimeSigEvent_throws__when_dataLength_isSuperiorTo_0x04() {
        buffer.putUInt8(0x05);
        buffer.rewind()
        XCTAssertThrowsSpecific(try processTimeSigEvent(buffer), exception: processingError.dataIsInvalidLengthForEventType(eMidiEventType.timeSignature, length: 0, kOrpheeDebug_metaEventProc_timeSigDataInvalidLength))
    }

    func testProcessTimeSigEvent_return_formattedData__when_dataLength_IsEqualTo_0x04__and_dataIs_defaultTimeSigData() {
        buffer.putUInt8(0x04)
        buffer.putUInt8(kMIDIEventDefaultData_timeSig)
        buffer.rewind()

        XCTAssertEqual(try! processTimeSigEvent(buffer), [0x04, 0x04, 0x18, 0x08])
    }

    func testProcessTimeSigEvent_return_formattedData__when_dataLength_IsEqualTo_0x04__and_dataIsNot_defaultTimeSigData() {
        buffer.putUInt8(0x04)
        buffer.putUInt8([0x18, 0x04, 0xFF, 0x01])
        buffer.rewind()

        XCTAssertEqual(try! processTimeSigEvent(buffer), [0x18, 0x10, 0xFF, 0x01])
    }


    // MARK: processTimeSigEvent()
    func testProcessTempoEvent_throws__when_dataLength_isInferiorTo_0x03() {
        buffer.putUInt8(0x02);
        buffer.rewind();

        XCTAssertThrowsSpecific(try processTempoEvent(buffer), exception: processingError.dataIsInvalidLengthForEventType(eMidiEventType.timeSignature, length: 0, kOrpheeDebug_metaEventProc_timeSigDataInvalidLength))
    }

    func testProcessTempoEvent_throws__when_dataLength_isSuperiorTo_0x03() {
        buffer.putUInt8(0x05);
        buffer.rewind()
        XCTAssertThrowsSpecific(try processTempoEvent(buffer), exception: processingError.dataIsInvalidLengthForEventType(eMidiEventType.timeSignature, length: 0, kOrpheeDebug_metaEventProc_timeSigDataInvalidLength))
    }

    func testProcessTempoEvent_return_formattedData__when_dataLength_IsEqualTo_0x03__and_dataIs_defaultSetTempoData() {
        buffer.putUInt8(0x03)
        buffer.putUInt8(kMIDIEventDefaultData_setTempo)
        buffer.rewind()

        XCTAssertEqual(try! processTempoEvent(buffer), [120])
    }

    func testProcessTempoEvent_return_formattedData__when_dataLength_IsEqualTo_0x03__and_dataIsNot_defaultSetTempoData() {
        buffer.putUInt8(0x03)
        buffer.putUInt8([0x02, 0xDC, 0x6C])
        buffer.rewind()

        XCTAssertEqual(try! processTempoEvent(buffer), [320])
    }


    // MARK: processUnknownEvent()
    func testProcessUnknownEvent_returns_formattedInputData__when_buffer_contains_only_runningStatusBytes() {
        buffer.putUInt8([0x01, 0x05, 0x7F, 0x00, 0x23, 0x51, 0x58, 0x75])
        buffer.rewind();

        XCTAssertEqual(processUnknownEvent(buffer), [0x01, 0x05, 0x7F, 0x00, 0x23, 0x51, 0x58, 0x75]);
    }

    func testProcessUnknownEvent_returns_formattedInputData__when_buffer_contains_runningStatusBytes__and_metaBytes() {
        buffer.putUInt8([0x01, 0x05, 0x7E, 0xFF, 0x23, 0x51, 0x58, 0x75])
        buffer.rewind();

        XCTAssertEqual(processUnknownEvent(buffer), [0x01, 0x05, 0x7E, 0xFF])
        XCTAssertEqual(processUnknownEvent(buffer), [0x23, 0x51, 0x58, 0x75]);
    }
}
