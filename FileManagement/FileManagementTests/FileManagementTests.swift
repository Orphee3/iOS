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

@testable import FileManagement

class FileManagementTests: XCTestCase {

    var fm: pFormattedFileManager? = nil;

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        fm = MIDIFileManager(name: "test");
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCreateFile_succeeds__using_CoreMIDISequenceCreator() {
        let n1 = MIDINoteMessage(channel: 0, note: 50, velocity: 76, releaseVelocity: 0, duration: eNoteLength.crotchet.rawValue);
        let n2 = MIDINoteMessage(channel: 0, note: 60, velocity: 86, releaseVelocity: 0, duration: eNoteLength.crotchet.rawValue);
        let testContent: [String : Any] = [kOrpheeFileContent_tracks: [0: [[n1, n2, n1, n2], [], [n1, n2], [], [n1, n2], []]]];

        precondition(fm as? MIDIFileManager != nil);
        XCTAssertTrue(fm!.createFile(nil))
        XCTAssertTrue(fm!.writeToFile(content: testContent, dataBuilderType: CoreMIDISequenceCreator.self))
}

    func testCreateFile_succeeds__using_MIDIByteBufferCreator() {

        let n1 = MIDINoteMessage(channel: 0, note: 50, velocity: 76, releaseVelocity: 0, duration: eNoteLength.crotchet.rawValue);
        let n2 = MIDINoteMessage(channel: 0, note: 60, velocity: 86, releaseVelocity: 0, duration: eNoteLength.crotchet.rawValue);
        let testContent: [String : Any] = [kOrpheeFileContent_tracks: [0: [[n1, n2, n1, n2], [], [n1, n2], [], [n1, n2], []]]];


        precondition(fm as? MIDIFileManager != nil);

        fm = MIDIFileManager(name: "test2");
        XCTAssertTrue(fm!.createFile(nil))
        XCTAssertTrue(fm!.writeToFile(content: testContent, dataBuilderType: MIDIByteBufferCreator.self));
    }

    func testReadFile_succeeds__when_file_wasCreatedBy_MIDIByteBufferCreator() {
        fm = MIDIFileManager(name: "test2");
        precondition(fm as? MIDIFileManager != nil);
        XCTAssertNotNil(fm!.readFile(), "Pass");
    }

    func testReadFile_succeeds__when_file_wasCreatedBy_CoreMIDISequenceCreator() {
        precondition(fm as? MIDIFileManager != nil);
        XCTAssertNotNil(fm!.readFile(), "Pass");
    }
    
    func testGenericEventBuild() {

        let event = TimedMidiEvent<ByteBuffer>(type: eMidiEventType.noteOn, deltaTime: 5) { (rawData) -> [UInt32] in
            return [5];
        }

        XCTAssert(event.type == eMidiEventType.noteOn, "Bad type init");
        XCTAssert(event.deltaTime == 5, "Bad delta init");
        try! event.readData(ByteBuffer(order: LittleEndian(), capacity: 10));
        XCTAssert(event.data! == [5], "Bad reader init");
    }
}
