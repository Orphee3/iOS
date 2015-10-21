//
//  MidiEventsProcessorsHelpersTests.swift
//  FileManagement
//
//  Created by JohnBob on 31/08/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import XCTest

@testable import FileManagement


class MidiEventsProcessorsHelpersTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    /*#############################
    ####### isSysResetByte #######
    #############################*/
    func testIsMetaEventByte_returns_true__when_currentByteIs_equalTo_0xFF() {
        XCTAssert(isSysResetByte(0xFF));
    }

    func testIsMetaEventByte_returns_false__when_currentByteIs_notEqualTo_0xFF() {
        XCTAssertFalse(isSysResetByte(0xEF));
    }

    /*#############################
    ####### getChanForEvent #######
    #############################*/
    func testGetChanForEventType_returns_0__when_eventTypeIs_unknown_or_runningStatus() {

        XCTAssertEqual(try! getChanForEventType(eMidiEventType.unknown, fromByte: 0x45), 0);
        XCTAssertEqual(try! getChanForEventType(eMidiEventType.runningStatus, fromByte: 0x45), 0);
    }

    func testGetChanForEventType_throws_invalidMidiEvent__when_eventTypeIsNot_aMidiEventType() {
        for case let type in eMidiEventType.allEvents where !eMidiEventType.allMIDIEvents.contains(type) {
            XCTAssertThrowsSpecific(try getChanForEventType(type, fromByte: 0x45),
                exception: eMidiEventType.eMidiEventTypeErrors.invalidMidiEvent(byte: 0x45, ""))
        }
    }

    func testGetChanForEventType_throws_byteIsNotOfGivenType__when_eventTypeIs_aMidiEventType__and_byteIs_notConstruedAs_MidiEventType() {
        for case let type in eMidiEventType.allMIDIEvents {
            for byte in UInt8(0x10)...UInt8(0x1F) {
                XCTAssertThrowsSpecific(try getChanForEventType(type, fromByte: byte), exception: eMidiEventType.eMidiEventTypeErrors.byteIsNotOfGivenType(byte: byte, type: type, ""))
            }
        }
    }

    func testGetChanForEventType_returns_validChannel__when_eventTypeIs_aMidiEventType__and_byteIs_construedAs_same_type() {
        for case let type in eMidiEventType.allMIDIEvents {
            for byte in UInt8(0x00)...UInt8(0x0F) {
                XCTAssertEqual(try! getChanForEventType(type, fromByte: type.rawValue + byte), byte);
            }
        }
    }

    /*#############################
    ######### peakNextByte ########
    #############################*/
    func testPeakNextByte_throws__when_bufferIs_empty() {
        let b = ByteBuffer(order: LittleEndian(), capacity: 0);
        XCTAssertThrows(try peakNextByte(b));
    }

    func testPeakNextByte_throws__when_bufferIs_notEmpty__and_nothingRemainsToBeRead() {
        let b = ByteBuffer(order: LittleEndian(), capacity: 4);
        b.putUInt8([0x00, 0xFF, 0x51, 0x04]);
        XCTAssertThrows(try peakNextByte(b));
    }

    func testPeakNextByte_returns_expectedValue__when_bufferIs_notEmpty() {
        let b = ByteBuffer(order: LittleEndian(), capacity: 4);
        b.putUInt8([0x00, 0xFF, 0x51, 0x04]);
        b.rewind();
        XCTAssertEqual(try! peakNextByte(b), 0x00);
        b.getUInt8();
        XCTAssertEqual(try! peakNextByte(b), 0xFF);
        b.getUInt8();
        XCTAssertEqual(try! peakNextByte(b), 0x51);
        b.getUInt8();
        XCTAssertEqual(try! peakNextByte(b), 0x04);
        b.getUInt8();
    }

    func testPeakNextByte_resets_inBufferPosition_toBeforeCallState__when_notThrowing() {
        let b = ByteBuffer(order: LittleEndian(), capacity: 4);
        b.putUInt8([0x00, 0xFF, 0x51, 0x04]);
        b.rewind();
        let pos = b.position;
        let _ = try! peakNextByte(b);
        XCTAssertEqual(pos, b.position);
    }

    func testPeakNextByte_resets_inBufferPosition_toBeforeCallState__after_throwing_when_bufferIs_empty() {
        let b = ByteBuffer(order: LittleEndian(), capacity: 0);
        let pos = b.position;
        XCTAssertThrows(try peakNextByte(b));
        XCTAssertEqual(pos, b.position);
    }

    func testPeakNextByte_resets_inBufferPosition_toBeforeCallState__after_throwing_when_bufferIs_notEmpty() {
        let b = ByteBuffer(order: LittleEndian(), capacity: 4);
        b.putUInt8([0x00, 0xFF, 0x51, 0x04]);
        let pos = b.position;
        XCTAssertThrows(try peakNextByte(b));
        XCTAssertEqual(pos, b.position);
    }

    /*#############################
    ###### getNextStatusByte ######
    #############################*/
    func testGetNextStatusByte_throws__when_bufferIs_empty() {
        var meta = false
        let b = ByteBuffer(order: LittleEndian(), capacity: 0);
        XCTAssertThrows(try getNextStatusByte(b, isMeta: &meta));
    }

    func testGetNextStatusByte_throws__when_bufferIs_notEmpty__and_nothingRemainsToBeRead() {
        var meta = false
        let b = ByteBuffer(order: LittleEndian(), capacity: 4);
        b.putUInt8([0x00, 0xFF, 0x51, 0x04]);
        XCTAssertThrows(try getNextStatusByte(b, isMeta: &meta));
    }

    func testGetNextStatusByte_resets_inBufferPosition_toBeforeCallState__after_throwing__when_metaIs_false() {
        var meta = false
        let b = ByteBuffer(order: LittleEndian(), capacity: 4);
        b.putUInt8([0xFF, 0xFF, 0x00, 0x00]);
        b.rewind();
        b.getUInt8();
        let pos = b.position;
        XCTAssertThrows(try getNextStatusByte(b, isMeta: &meta));
        XCTAssertEqual(b.position, pos);
    }

    func testGetNextStatusByte_resets_inBufferPosition_toBeforeCallState__after_throwing__when_metaIs_true() {
        var meta = true
        let b = ByteBuffer(order: LittleEndian(), capacity: 4);
        b.putUInt8([0xFF, 0xFF, 0x00, 0x00]);
        b.rewind();
        b.getUInt8();
        let pos = b.position;
        XCTAssertThrows(try getNextStatusByte(b, isMeta: &meta));
        XCTAssertEqual(b.position, pos);
    }

    func testGetNextStatusByte_sets_inBufferPosition_to_nextPosition__when_metaIs_false__and_buffer_doesNotContain_0x00_or_0xFF() {
        let b = ByteBuffer(order: LittleEndian(), capacity: 4);
        b.putUInt8([0xEF, 0x2F, 0x04, 0x58]);
        b.rewind();
        repeat {
            var meta = false
            let pos = b.position + 1
            let _ = try! getNextStatusByte(b, isMeta: &meta)
            XCTAssertEqual(b.position, pos);
            b.getUInt8();
        } while (b.hasRemaining);
    }

    func testGetNextStatusByte_sets_inBufferPosition_to_positionOfFirstByte_differentFrom_0x00_and_0xFF__when_metaIs_false() {
        func peakNextValidBytePosition(buf: ByteBuffer) -> Int {
            buf.mark();
            defer {
                buf.reset();
            }
            repeat  {
                let position = buf.position; // For debugger
                let byte = buf.getUInt8()
                guard byte == 0x00 || byte == 0xFF else {
                    return buf.position
                }
            } while (buf.hasRemaining);
            return 0
        }

        let b = ByteBuffer(order: LittleEndian(), capacity: 8);
        b.putUInt8([0x00, 0xFF, 0x58, 0x04, 0x04, 0x02, 0x18, 0x08]);
        b.rewind();
        repeat {
            var meta = false
            let validBytePos = peakNextValidBytePosition(b);
            let readByte = try! getNextStatusByte(b, isMeta: &meta);
            XCTAssertNotEqual(readByte, 0x00);
            XCTAssertEqual(b.position, validBytePos);
            let _ = (b.position, validBytePos); // For debugger;
        } while (b.hasRemaining);
    }

    func testGetNextStatusByte_sets_inBufferPosition_to_positionOfFirstByte_differentFrom_0x00_and_0xFF__when_metaIs_true() {
        func peakNextValidBytePosition(buf: ByteBuffer) -> Int {
            buf.mark();
            defer {
                buf.reset();
            }
            repeat  {
                let position = buf.position; // For debugger
                let byte = buf.getUInt8()
                if case _ = byte where byte != 0x00 && byte != 0xFF {
                    return buf.position;
                }
            } while (buf.hasRemaining);
            return 0
        }

        let b = ByteBuffer(order: LittleEndian(), capacity: 8);
        b.putUInt8([0x00, 0xFF, 0x58, 0x04, 0x04, 0x02, 0x18, 0x08]);
        b.rewind();
        repeat {
            var meta = true
            let validBytePos = peakNextValidBytePosition(b);
            XCTAssertNotEqual(try! getNextStatusByte(b, isMeta: &meta), 0x00);
            XCTAssertEqual(b.position, validBytePos);
            let _ = (b.position, validBytePos); // For debugger;
        } while (b.hasRemaining);
    }

    func testGetNextStatusByte_returns_firstByte_differentFrom_0x00_and_0xFF__when_metaIs_false__and_bufferIs_notEmpty() {
        func peakNextValidByteAndPosition(buf: ByteBuffer) -> (UInt8, Int) {
            buf.mark();
            defer {
                buf.reset();
            }
            repeat  {
                if case let byte = buf.getUInt8() where byte != 0x00 && byte != 0xFF {
                    return (byte, buf.position);
                }
            } while (buf.hasRemaining);
            return (0, 0);
        }

        let b = ByteBuffer(order: LittleEndian(), capacity: 8);
        b.putUInt8([0x00, 0xFF, 0x58, 0x04, 0x04, 0x02, 0x18, 0x08]);
        b.rewind();
        repeat {
            var meta = false
            let (validByte, pos) = peakNextValidByteAndPosition(b);
            let readByte = try! getNextStatusByte(b, isMeta: &meta);
            XCTAssertEqual(readByte, validByte);
        } while (b.hasRemaining);
    }

    func testGetNextStatusByte_returns_firstByte_differentFrom_0x00_and_0xFF__when_metaIs_true__and_bufferIs_notEmpty() {
        func peakNextValidByteAndPosition(buf: ByteBuffer) -> (UInt8, Int) {
            buf.mark();
            defer {
                buf.reset();
            }
            repeat  {
                if case let byte = buf.getUInt8() where byte != 0x00 && byte != 0xFF {
                    return (byte, buf.position);
                }
            } while (buf.hasRemaining);
            return (0, 0);
        }

        let b = ByteBuffer(order: LittleEndian(), capacity: 8);
        b.putUInt8([0x00, 0xFF, 0x58, 0x04, 0xFF, 0x04, 0x02, 0x18]);
        b.rewind();
        repeat {
            var meta = true
            let (validByte, _) = peakNextValidByteAndPosition(b);
            XCTAssertEqual(try! getNextStatusByte(b, isMeta: &meta), validByte);
//            XCTAssertEqual(pos, b.position);
        } while (b.hasRemaining);
    }

    /*#############################
    ###### processStatusByte ######
    #############################*/
    func testProcessStatusByte_returns_unknownEvent__when_metaIs_true__byteIs_superiorTo_0x7F() {
        for case let byte: UInt8 in 0x80..<0xFF {
            XCTAssertEqual(processStatusByte(byte, isMeta: true), eMidiEventType.unknown);
        }
    }

    func testProcessStatusByte_returns_unknownEvent__when_metaIs_true__byteIs_inferiorOrEqualTo_0x7F__and_isNot_definedMetaEvent() {
        XCTAssertEqual(processStatusByte(0x09, isMeta: true), eMidiEventType.unknown);
        XCTAssertEqual(processStatusByte(0x35, isMeta: true), eMidiEventType.unknown);
        XCTAssertEqual(processStatusByte(0x55, isMeta: true), eMidiEventType.unknown);
        XCTAssertEqual(processStatusByte(0x7E, isMeta: true), eMidiEventType.unknown);
    }

    func testProcessStatusByte_returns_unknownEvent__when_metaIs_true__byteIs_inferiorOrEqualTo_0x7F__and_is_unsupportedMetaEvent() {
        XCTAssertEqual(processStatusByte(0x00, isMeta: true), eMidiEventType.unknown);
        XCTAssertEqual(processStatusByte(0x20, isMeta: true), eMidiEventType.unknown);
        XCTAssertEqual(processStatusByte(0x54, isMeta: true), eMidiEventType.unknown);
        XCTAssertEqual(processStatusByte(0x7F, isMeta: true), eMidiEventType.unknown);
    }

    func testProcessStatusByte_returns_unknownEvent__when_metaIs_false__byteIs_between_0x80_and_0xEF__and_is_unsupportedMidiEvent() {
        XCTAssertEqual(processStatusByte(0xA0, isMeta: false), eMidiEventType.unknown);
        XCTAssertEqual(processStatusByte(0xBD, isMeta: false), eMidiEventType.unknown);
        XCTAssertEqual(processStatusByte(0xDB, isMeta: false), eMidiEventType.unknown);
        XCTAssertEqual(processStatusByte(0xEF, isMeta: false), eMidiEventType.unknown);
    }

    func testProcessStatusByte_returns_unknownEvent__when_metaIs_false__byteIs_superiorTo_0xEF() {
        for case let byte: UInt8 in 0xF0..<0xFF {
            XCTAssertEqual(processStatusByte(byte, isMeta: false), eMidiEventType.unknown);
        }
    }

    func testProcessStatusByte_returns_runningStatus__when_metaIs_false__byteIs_inferiorOrEqualTo_0x7F__and_isNot_definedMetaEvent() {
        XCTAssertEqual(processStatusByte(0x09, isMeta: false), eMidiEventType.runningStatus);
        XCTAssertEqual(processStatusByte(0x35, isMeta: false), eMidiEventType.runningStatus);
        XCTAssertEqual(processStatusByte(0x55, isMeta: false), eMidiEventType.runningStatus);
        XCTAssertEqual(processStatusByte(0x7E, isMeta: false), eMidiEventType.runningStatus);
    }

    func testProcessStatusByte_returns_runningStatus__when_metaIs_false__byteIs_inferiorOrEqualTo_0x7F__and_is_unsupportedMetaEvent() {
        XCTAssertEqual(processStatusByte(0x00, isMeta: false), eMidiEventType.runningStatus);
        XCTAssertEqual(processStatusByte(0x20, isMeta: false), eMidiEventType.runningStatus);
        XCTAssertEqual(processStatusByte(0x54, isMeta: false), eMidiEventType.runningStatus);
        XCTAssertEqual(processStatusByte(0x7F, isMeta: false), eMidiEventType.runningStatus);
    }

    func testProcessStatusByte_returns_runningStatus__when_metaIs_false__byteIs_inferiorOrEqualTo_0x7F__and_is_supportedMetaEvent() {
        for case let eventType in eMidiEventType.METAEvents {
            XCTAssertEqual(processStatusByte(eventType.rawValue, isMeta: false), eMidiEventType.runningStatus);
        }
    }

    func testProcessStatusByte_returns_supportedMidiEvent__when_metaIs_false__byteIs_supportedMidiEventRawValue() {
        for case let eventType in eMidiEventType.MIDIEvents {
            XCTAssertEqual(processStatusByte(eventType.rawValue, isMeta: false), eventType);
        }
    }

    func testProcessStatusByte_returns_supportedMidiEvent__when_metaIs_false__byteIs_supportedMidiEvent() {
        for case let eventType in eMidiEventType.MIDIEvents {
            for case let byte: UInt8 in 0x00...0x0f {
                XCTAssertEqual(processStatusByte(eventType.rawValue + byte, isMeta: false), eventType);
            }
        }
    }

    func testProcessStatusByte_returns_supportedMetaEvent_when_metaIs_true__byteIs_supportedMetaEventRawValue() {
        for case let eventType in eMidiEventType.METAEvents {
            XCTAssertEqual(processStatusByte(eventType.rawValue, isMeta: true), eventType);
        }
    }

    /*#############################
    ######## makeMidiEvent ########
    #############################*/
    func testMakeMidiEvent_returns_instanceOf_TimedMidiEvent__when_eventTypeIs_definedMidiEvent() {
        for eventType in eMidiEventType.allMIDIEvents {
            let testEvent = makeMidiEvent(eventType);
            let ctrlEvent = TimedMidiEvent(type: eventType, deltaTime: 0, reader: processUnknownEvent);
            testEvent.data = [];
            ctrlEvent.data = [];
            XCTAssertEqual(NSStringFromClass(testEvent.dynamicType), NSStringFromClass(TimedMidiEvent<ByteBuffer>));
            XCTAssertEqual(testEvent, ctrlEvent);
        }
    }

    func testMakeMidiEvent_returns_instanceOf_BasicMidiEvent__when_eventType_isNot_defineMidiEvent() {
        for eventType in eMidiEventType.allValues.subtract(eMidiEventType.allMIDIEvents) {
            let testEvent = makeMidiEvent(eventType);
            let ctrlEvent = BasicMidiEvent(type: eventType, reader: processUnknownEvent);
            testEvent.data = [];
            ctrlEvent.data = [];
            XCTAssertEqual(NSStringFromClass(makeMidiEvent(eventType).dynamicType), NSStringFromClass(BasicMidiEvent<ByteBuffer>));
            XCTAssertEqual(testEvent, ctrlEvent);
        }
    }

}
