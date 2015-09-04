//
//  FileManagementTests.swift
//  FileManagementTests
//
//  Created by JohnBob on 21/03/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit
import XCTest
import AudioToolbox

class FileManagementTests: XCTestCase {

    var fm: pFormattedFileManager? = nil;

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        fm = MIDIFileManager<MIDIByteBufferCreator>(name: "test");
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testReadWrite() {

        let n1 = MIDINoteMessage(channel: 0, note: 50, velocity: 76, releaseVelocity: 0, duration: eNoteLength.crotchet.rawValue);
        let n2 = MIDINoteMessage(channel: 0, note: 60, velocity: 86, releaseVelocity: 0, duration: eNoteLength.crotchet.rawValue);

        XCTAssertNotNil(fm as! MIDIFileManager<MIDIByteBufferCreator>, "File manager is nil");
        XCTAssertTrue(fm!.createFile(nil, content: [kOrpheeFileContent_tracks: [0: [[n1, n2, n1, n2], [], [n1, n2], [], [n1, n2], []]]]), "Pass")
        XCTAssertNotNil(fm!.readFile(nil), "Pass");

        fm = MIDIFileManager<CoreMIDISequenceCreator>(name: "test2");
        XCTAssertTrue(fm!.createFile(nil, content: [kOrpheeFileContent_tracks: [0: [[n1, n2, n1, n2], [], [n1, n2], [], [n1, n2], []]]]), "Pass")
        XCTAssertNotNil(fm!.readFile(nil), "Pass");
    }

    func testGenericEventBuild() {

        let event = TimedEvent<ByteBuffer>(type: eMidiEventType.noteOn, deltaTime: 5) { (rawData) -> [UInt32] in
            return [5];
        }

        XCTAssert(event.type == eMidiEventType.noteOn, "Bad type init");
        XCTAssert(event.deltaTime == 5, "Bad delta init");
        event.readData(ByteBuffer(order: LittleEndian(), capacity: 10));
        XCTAssert(event.data! == [5], "Bad reader init");
    }

    func testGetNextEvent() {

        var test: Bool = false;
        let b1: ByteBuffer = ByteBuffer(order: BigEndian(), capacity: 8);
        let b2: ByteBuffer = ByteBuffer(order: BigEndian(), capacity: 8);

        b1.putUInt32(0x00FF5806);
        b2.putUInt32(0x00005846);

        b1.position = 0;
        b2.position = 0;

        let b1Pos = b1.position;
        let res1 = getNextEvent(b1, isMetaEvent: &test);
        XCTAssert(res1 == 0x58, "Wrong output! Got \(res1)");
        XCTAssert(b1Pos != b1.position, "Wrong position! \(b1Pos) == \(b1.position)");
        print("position: \(b1.position), Byte: \(res1)");

        let b2Pos = b2.position;
        let res2 = getNextEvent(b2, isMetaEvent: &test);
        XCTAssert(res2 == 0x58, "Wrong output! Got \(res2)");
        XCTAssert(b2Pos != b2.position, "Wrong position! \(b2Pos) == \(b2.position)");
        print("position: \(b2.position), Byte: \(res2)");
    }
    
}
