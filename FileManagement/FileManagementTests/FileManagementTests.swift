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

import MIDIToolbox

@testable import FileManagement

class FileManagementTests: XCTestCase {

    var fm: pFormattedFileManager? = nil;

    let n1: MIDINoteMessage = MIDINoteMessage(channel: 0, note: 50, velocity: 76, releaseVelocity: 0, duration: eNoteLength.crotchet.rawValue);
    let n2 = MIDINoteMessage(channel: 0, note: 60, velocity: 86, releaseVelocity: 0, duration: eNoteLength.crotchet.rawValue);

    var testContent: [String : Any] = [:]

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        testContent = [
                eOrpheeFileContent.Tracks.rawValue: [
                0: [[n1], [], [], [n1, n2], [], [], [n1, n2], []],
                1: [[n2], [], [n1], [], [], [n2], [], [], [n2, n1]],
                2: [[], [], []]
            ],
                eOrpheeFileContent.TracksInfos.rawValue: [
                0 : [eOrpheeFileContent.PatchID.rawValue : 1 as Any],
                1 : [eOrpheeFileContent.PatchID.rawValue : 34 as Any],
                2 : [eOrpheeFileContent.PatchID.rawValue : 1 as Any]
            ]
        ];

        try! NSFileManager.defaultManager().createDirectoryAtPath(MIDIFileManager.store, withIntermediateDirectories: true, attributes: nil);
        fm = MIDIFileManager(name: "test");
    }

    override func tearDown() {
        fm?.deleteFile()

        super.tearDown()
    }

    func testCreateFile_succeeds() {
        precondition(fm as? MIDIFileManager != nil);

        XCTAssertTrue(fm!.createFile())
    }

    func testCreateFile_succeeds__and_sets_givenName() {
        precondition(fm as? MIDIFileManager != nil);

        XCTAssertTrue(fm!.createFile("toto"))
        XCTAssertEqual(fm!.name, "toto" + "." + MIDIFileManager.ext);
    }

    func testDeleteFile_succeeds() {
        precondition(fm!.createFile())
        precondition(NSFileManager.defaultManager().fileExistsAtPath(fm!.path))

        fm!.deleteFile()
        XCTAssertFalse(NSFileManager.defaultManager().fileExistsAtPath(fm!.path))
    }

    func testWriteToFile_succeeds__using_MIDIByteBufferCreator() {
        precondition(fm as? MIDIFileManager != nil);
        precondition(fm!.createFile())

        XCTAssertTrue(fm!.writeToFile(content: testContent, dataBuilderType: MIDIByteBufferCreator.self));

        try? NSFileManager.defaultManager().copyItemAtPath((fm as! MIDIFileManager).path, toPath: "/Users/johnbob/Desktop/testByteBuffer.mid");
    }

    func testWriteToFile_fails__using_MIDIByteBufferCreator__when_contentIs_nil() {
        precondition(fm as? MIDIFileManager != nil);
        precondition(fm!.createFile())

        XCTAssertFalse(fm!.writeToFile(content: nil, dataBuilderType: MIDIByteBufferCreator.self));
    }

    func testWriteToFile_fails__using_MIDIByteBufferCreator__when_content_containsNo_tracks() {
        precondition(fm as? MIDIFileManager != nil);
        precondition(fm!.createFile())

        testContent.removeValueForKey(eOrpheeFileContent.Tracks.rawValue)
        XCTAssertFalse(fm!.writeToFile(content: testContent, dataBuilderType: MIDIByteBufferCreator.self));
    }

    func testWriteToFile_fails__using_MIDIByteBufferCreator__when_content_containsNo_trackInfos() {
        precondition(fm as? MIDIFileManager != nil);
        precondition(fm!.createFile())

        testContent.removeValueForKey(eOrpheeFileContent.TracksInfos.rawValue)
        XCTAssertFalse(fm!.writeToFile(content: testContent, dataBuilderType: MIDIByteBufferCreator.self));
    }

    func testWriteToFile_succeeds__using_CoreMIDISequenceCreator() {

        precondition(fm as? MIDIFileManager != nil);

        precondition(fm!.createFile())
        XCTAssertTrue(fm!.writeToFile(content: testContent, dataBuilderType: CoreMIDISequenceCreator.self))

        try? NSFileManager.defaultManager().copyItemAtPath((fm as! MIDIFileManager).path, toPath: "/Users/johnbob/Desktop/testCoreMIDI.mid");
    }

    func testWriteToFile_fails__using_CoreMIDISequenceCreator__when_contentIs_nil() {
        precondition(fm as? MIDIFileManager != nil);
        precondition(fm!.createFile())

        XCTAssertFalse(fm!.writeToFile(content: nil, dataBuilderType: CoreMIDISequenceCreator.self));
    }

    func testWriteToFile_fails__using_CoreMIDISequenceCreator__when_content_containsNo_tracks() {
        precondition(fm as? MIDIFileManager != nil);
        precondition(fm!.createFile())

        testContent.removeValueForKey(eOrpheeFileContent.Tracks.rawValue)
        XCTAssertFalse(fm!.writeToFile(content: testContent, dataBuilderType: CoreMIDISequenceCreator.self));
    }

    func testWriteToFile_fails__using_CoreMIDISequenceCreator__when_content_containsNo_trackInfos() {
        precondition(fm as? MIDIFileManager != nil);
        precondition(fm!.createFile())

        testContent.removeValueForKey(eOrpheeFileContent.TracksInfos.rawValue)
        XCTAssertFalse(fm!.writeToFile(content: testContent, dataBuilderType: CoreMIDISequenceCreator.self));
    }

    func testReadFile_succeeds__when_file_wasCreatedBy_MIDIByteBufferCreator() {

        precondition(fm as? MIDIFileManager != nil);
        precondition(fm!.createFile())
        precondition(fm!.writeToFile(content: testContent, dataBuilderType: MIDIByteBufferCreator.self));

        XCTAssertNotNil(fm!.readFile(), "Pass");
    }

    func testReadFile_succeeds__when_file_wasCreatedBy_CoreMIDISequenceCreator() {
        precondition(fm as? MIDIFileManager != nil);
        precondition(fm!.createFile())
        precondition(fm!.writeToFile(content: testContent, dataBuilderType: CoreMIDISequenceCreator.self))

        XCTAssertNotNil(fm!.readFile(), "Pass");
    }
}
