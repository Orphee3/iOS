//
//  MIDIReaderTests.swift
//  FileManagement
//
//  Created by John Bobington on 17/12/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import XCTest

@testable import FileManagement

class MIDIReaderTests: XCTestCase {

    var fm: NSFileManager!
    var bundle: NSBundle!
    var testPath: String!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        fm = NSFileManager.defaultManager()
        bundle = NSBundle(forClass: MIDIReaderTests.self)
        testPath = self.bundle!.resourcePath! + "/tata"

        fm!.createFileAtPath(testPath, contents: testPath.dataUsingEncoding(NSUTF8StringEncoding)!, attributes: nil)
    }

    override func tearDown() {

        fm = nil
        bundle = nil

        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testMIDIReaderInit__throws_when_path_isIncorrect() {
        XCTAssertThrows(try DefaultReader(path: ""));
    }

    func testMIDIReaderInit__throws_when_path_isWriteOnly() {

        precondition(fm.fileExistsAtPath(testPath))

        var attrs = try! fm.attributesOfFileSystemForPath(testPath)
        let defaultAttrs = attrs
        attrs[NSFilePosixPermissions] = NSNumber(short: 0o333);

        try! fm.setAttributes(attrs, ofItemAtPath: testPath);
        precondition(!fm.isReadableFileAtPath(testPath))

        XCTAssertThrows(try DefaultReader(path: testPath))

        try! fm.setAttributes(defaultAttrs, ofItemAtPath: testPath)
        try! fm.removeItemAtPath(testPath)
    }

    func testMIDIReaderInit__succeeds_when_pathIs_valid__and_pathIs_readable() {

        precondition(fm.fileExistsAtPath(testPath))
        precondition(fm.isReadableFileAtPath(testPath))

        XCTAssertDoesNotThrow(try DefaultReader(path: testPath))
    }

    func testMIDIReader_readAllData__succeeds() {

        precondition(fm.fileExistsAtPath(testPath))
        precondition(fm.isReadableFileAtPath(testPath))

        let writer = try! DefaultReader(path: testPath)

        XCTAssertEqual(writer.readAllData().length, try! fm.attributesOfItemAtPath(testPath)[NSFileSize]! as! Int)
    }

    func testMIDIReader_read__succeeds() {

        precondition(fm.fileExistsAtPath(testPath))
        precondition(fm.isReadableFileAtPath(testPath))

        let writer = try! DefaultReader(path: testPath)

        XCTAssertEqual(writer.read(size: 100).length, 100)
        XCTAssertEqual(writer.read(size: 50).length, 50)
    }

    func testMIDIReader_read__succeeds__and_resets_fileOffsetTo_0__when_EOFIs_reached() {

        precondition(fm.fileExistsAtPath(testPath))
        precondition(fm.isReadableFileAtPath(testPath))

        let writer = try! DefaultReader(path: testPath)

        XCTAssertEqual(writer.read(size: 197).length, 197)
        XCTAssertEqual(writer.read(size: 197).length, 197)
    }

    func testMIDIReader_read__doesNot_read_beyondFileSize__when_providedWith_readSize_superiorTo_fileSize() {

        precondition(fm.fileExistsAtPath(testPath))
        precondition(fm.isReadableFileAtPath(testPath))

        let writer = try! DefaultReader(path: testPath)

        XCTAssertEqual(writer.read(size: 500).length, 197)
    }

    func testMIDIReader_getEOFposition__returns_positionOf_EOF() {
        precondition(fm.fileExistsAtPath(testPath))
        precondition(fm.isReadableFileAtPath(testPath))

        let writer = try! DefaultReader(path: testPath)

        XCTAssertEqual(writer.getEOFposition(), 197)
    }
}
