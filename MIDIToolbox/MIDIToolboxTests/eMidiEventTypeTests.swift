//
//  eMidiEventTypeTests.swift
//  FileManagement
//
//  Created by JohnBob on 30/08/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import XCTest
@testable import MIDIToolbox

extension eMidiEventType.eMidiEventTypeError :Equatable {}

public func ==(lhs: eMidiEventType.eMidiEventTypeError, rhs: eMidiEventType.eMidiEventTypeError) -> Bool {

    switch(lhs, rhs) {
    case (.invalidMetaEvent(_, _), .invalidMetaEvent(_, _)):
        return true;
    case (.invalidMidiEvent(_, _), .invalidMidiEvent(_, _)):
        return true;
    case (.tooManyEventsForByte(_, _), .tooManyEventsForByte(_, _)):
        return true;
    case (.byteIsNotOfGivenType(_, _, _), .byteIsNotOfGivenType(_, _, _)):
        return true;
    default:
        return false;
    }
}

class eMidiEventTypeTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    /*#############################
    ### isByte:aMidiEventOfType ###
    #############################*/
    func testIsByteAMidiEventOfType_throws_invalidMidiEvent__when_eventTypeIs_nonMidiEventType() {
        for case let type in eMidiEventType.kAllEvents where !eMidiEventType.kAllMIDIEvents.contains(type) {
            XCTAssertThrowsSpecific(try eMidiEventType.isByte(0, aMidiEventOfType: type),
                exception: eMidiEventType.eMidiEventTypeError.invalidMidiEvent(byte: 0, ""));
        }
    }

    func testIsByteAMidiEventOfType_returns_false__when_eventTypeIs_midiEventType__and_byteIs_construedAs_different_type() {
        for case let type in eMidiEventType.kAllMIDIEvents {
            XCTAssertFalse(try! eMidiEventType.isByte(type.rawValue + 0x10, aMidiEventOfType: type));
        }
        for case let type in eMidiEventType.kAllMIDIEvents {
            XCTAssertFalse(try! eMidiEventType.isByte(type.rawValue + 0x15, aMidiEventOfType: type));
        }
    }

    func testIsByteAMidiEventOfType_returns_true__when_eventTypeIs_midiEventType__and_byteIs_construedAs_same_type() {
        for case let type in eMidiEventType.kAllMIDIEvents {
            XCTAssert(try! eMidiEventType.isByte(type.rawValue + 0x0F, aMidiEventOfType: type));
        }
        for case let type in eMidiEventType.kAllMIDIEvents {
            XCTAssert(try! eMidiEventType.isByte(type.rawValue + 0x00, aMidiEventOfType: type));
        }
    }

    /*#############################
    ##### getMidiEventTypeFor #####
    #############################*/
    func testGetMidiEventTypeFor_thows_invalidMetaEvent__when_metaIs_true__byteIs_superiorTo_0x7F() {
        for case let i: UInt8 in 0x80...0xFE {
            XCTAssertThrowsSpecific(try eMidiEventType.getMidiEventTypeFor(i, isMeta: true),
                exception: eMidiEventType.eMidiEventTypeError.invalidMetaEvent(byte: i, "")
            );
        }
    }

    func testGetMidiEventTypeFor_doesNotThow_tooManyEventsForByte__forAnyValue() {
        for case let i: UInt8 in 0...0xFE {
            XCTAssertDoesNotThrowSpecific(try eMidiEventType.getMidiEventTypeFor(i, isMeta: true),
                exception: eMidiEventType.eMidiEventTypeError.tooManyEventsForByte(byte: 0, ""));
        }
        for case let i: UInt8 in 0...0xFE {
            XCTAssertDoesNotThrowSpecific(try eMidiEventType.getMidiEventTypeFor(i, isMeta: false),
                exception: eMidiEventType.eMidiEventTypeError.tooManyEventsForByte(byte: 0, ""));
        }
    }

    func testGetMidiEventTypeFor_returns_unknownEvent__when_metaIs_true__byteIs_inferiorOrEqualTo_0x7F__and_isNot_definedMetaEvent() {
        XCTAssertEqual(try! eMidiEventType.getMidiEventTypeFor(0x09, isMeta: true), eMidiEventType.unknown);
        XCTAssertEqual(try! eMidiEventType.getMidiEventTypeFor(0x35, isMeta: true), eMidiEventType.unknown);
        XCTAssertEqual(try! eMidiEventType.getMidiEventTypeFor(0x55, isMeta: true), eMidiEventType.unknown);
        XCTAssertEqual(try! eMidiEventType.getMidiEventTypeFor(0x7E, isMeta: true), eMidiEventType.unknown);
    }

    func testGetMidiEventTypeFor_returns_unsupportedEvent__when_metaIs_true__byteIs_inferiorOrEqualTo_0x7F__and_is_unsupportedMetaEvent() {
        XCTAssertEqual(try! eMidiEventType.getMidiEventTypeFor(0x00, isMeta: true), eMidiEventType.unsupported);
        XCTAssertEqual(try! eMidiEventType.getMidiEventTypeFor(0x20, isMeta: true), eMidiEventType.unsupported);
        XCTAssertEqual(try! eMidiEventType.getMidiEventTypeFor(0x54, isMeta: true), eMidiEventType.unsupported);
        XCTAssertEqual(try! eMidiEventType.getMidiEventTypeFor(0x7F, isMeta: true), eMidiEventType.unsupported);
    }

    func testGetMidiEventTypeFor_returns_unsupportedEvent__when_metaIs_false__byteIs_between_0x80_and_0xEF__and_is_unsupportedMidiEvent() {
        XCTAssertEqual(try! eMidiEventType.getMidiEventTypeFor(0xA0, isMeta: false), eMidiEventType.unsupported);
        XCTAssertEqual(try! eMidiEventType.getMidiEventTypeFor(0xBD, isMeta: false), eMidiEventType.unsupported);
        XCTAssertEqual(try! eMidiEventType.getMidiEventTypeFor(0xDB, isMeta: false), eMidiEventType.unsupported);
        XCTAssertEqual(try! eMidiEventType.getMidiEventTypeFor(0xEF, isMeta: false), eMidiEventType.unsupported);
    }

    func testGetMidiEventTypeFor_returns_unknownEvent__when_metaIs_false__byteIs_superiorTo_0xEF() {
        XCTAssertEqual(try! eMidiEventType.getMidiEventTypeFor(0xF0, isMeta: false), eMidiEventType.unknown);
        XCTAssertEqual(try! eMidiEventType.getMidiEventTypeFor(0xF4, isMeta: false), eMidiEventType.unknown);
        XCTAssertEqual(try! eMidiEventType.getMidiEventTypeFor(0xF7, isMeta: false), eMidiEventType.unknown);
        XCTAssertEqual(try! eMidiEventType.getMidiEventTypeFor(0xFE, isMeta: false), eMidiEventType.unknown);
    }

    func testGetMidiEventTypeFor_returns_runningStatus__when_metaIs_false__byteIs_inferiorOrEqualTo_0x7F__and_isNot_definedMetaEvent() {
        XCTAssertEqual(try! eMidiEventType.getMidiEventTypeFor(0x09, isMeta: false), eMidiEventType.runningStatus);
        XCTAssertEqual(try! eMidiEventType.getMidiEventTypeFor(0x35, isMeta: false), eMidiEventType.runningStatus);
        XCTAssertEqual(try! eMidiEventType.getMidiEventTypeFor(0x55, isMeta: false), eMidiEventType.runningStatus);
        XCTAssertEqual(try! eMidiEventType.getMidiEventTypeFor(0x7E, isMeta: false), eMidiEventType.runningStatus);
    }

    func testGetMidiEventTypeFor_returns_runningStatus__when_metaIs_false__byteIs_inferiorOrEqualTo_0x7F__and_is_unsupportedMetaEvent() {
        XCTAssertEqual(try! eMidiEventType.getMidiEventTypeFor(0x00, isMeta: false), eMidiEventType.runningStatus);
        XCTAssertEqual(try! eMidiEventType.getMidiEventTypeFor(0x20, isMeta: false), eMidiEventType.runningStatus);
        XCTAssertEqual(try! eMidiEventType.getMidiEventTypeFor(0x54, isMeta: false), eMidiEventType.runningStatus);
        XCTAssertEqual(try! eMidiEventType.getMidiEventTypeFor(0x7F, isMeta: false), eMidiEventType.runningStatus);
    }

    func testGetMidiEventTypeFor_returns_runningStatus__when_metaIs_false__byteIs_inferiorOrEqualTo_0x7F__and_is_supportedMetaEvent() {
        XCTAssertEqual(try! eMidiEventType.getMidiEventTypeFor(0x2F, isMeta: false), eMidiEventType.runningStatus);
        XCTAssertEqual(try! eMidiEventType.getMidiEventTypeFor(0x51, isMeta: false), eMidiEventType.runningStatus);
        XCTAssertEqual(try! eMidiEventType.getMidiEventTypeFor(0x58, isMeta: false), eMidiEventType.runningStatus);
    }

    func testGetMidiEventTypeFor_returns_supportedMidiEvent__when_metaIs_false__byteIs_supportedMidiEventRawValue() {
        XCTAssertEqual(try! eMidiEventType.getMidiEventTypeFor(eMidiEventType.noteOn.rawValue, isMeta: false), eMidiEventType.noteOn);
        XCTAssertEqual(try! eMidiEventType.getMidiEventTypeFor(eMidiEventType.noteOff.rawValue, isMeta: false), eMidiEventType.noteOff);
        XCTAssertEqual(try! eMidiEventType.getMidiEventTypeFor(eMidiEventType.programChange.rawValue, isMeta: false), eMidiEventType.programChange);
    }

    func testGetMidiEventTypeFor_returns_supportedMidiEvent__when_metaIs_false__byteIs_supportedMidiEvent() {
        XCTAssertEqual(try! eMidiEventType.getMidiEventTypeFor(0x80, isMeta: false), eMidiEventType.noteOff);
        XCTAssertEqual(try! eMidiEventType.getMidiEventTypeFor(0x9D, isMeta: false), eMidiEventType.noteOn);
        XCTAssertEqual(try! eMidiEventType.getMidiEventTypeFor(0xCE, isMeta: false), eMidiEventType.programChange);
    }

    func testGetMidiEventTypeFor_returns_supportedMetaEvent_when_metaIs_true__byteIs_supportedMetaEventRawValue() {
        XCTAssertEqual(try! eMidiEventType.getMidiEventTypeFor(eMidiEventType.timeSignature.rawValue, isMeta: true), eMidiEventType.timeSignature);
        XCTAssertEqual(try! eMidiEventType.getMidiEventTypeFor(eMidiEventType.setTempo.rawValue, isMeta: true), eMidiEventType.setTempo);
        XCTAssertEqual(try! eMidiEventType.getMidiEventTypeFor(eMidiEventType.endOfTrack.rawValue, isMeta: true), eMidiEventType.endOfTrack);
    }
}

