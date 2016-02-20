//
//  MIDIWriterTests.swift
//  FileManagement
//
//  Created by John Bobington on 17/12/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import XCTest

@testable import FileManagement

class MIDIWriterTests: XCTestCase {

    var fm: NSFileManager? = nil
    var bundle: NSBundle? = nil

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        fm = NSFileManager.defaultManager()
        bundle = NSBundle(forClass: MIDIWriterTests.self)
    }

    override func tearDown() {

        fm = nil
        bundle = nil

        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testMIDIWriterInit__throws_when_path_isIncorrect() {
        XCTAssertThrows(try DefaultWriter(path: ""));
    }

    func testMIDIWriterInit__throws_when_path_isReadOnly() {

        let testPath = bundle!.resourcePath! + "/tata"

        precondition(fm!.createFileAtPath(testPath, contents: nil, attributes: [NSFileImmutable : true]))
        precondition(fm!.fileExistsAtPath(testPath))
        precondition(!fm!.isWritableFileAtPath(testPath))

        XCTAssertThrows(try DefaultWriter(path: testPath))

        try! fm!.setAttributes([NSFileImmutable : false], ofItemAtPath: testPath)
        try! fm!.removeItemAtPath(testPath)
    }

    func testMIDIWriterInit__succeeds_when_pathIs_valid__and_pathIs_writable() {
        let testPath = bundle!.resourcePath! + "/tata"

        precondition(fm!.createFileAtPath(testPath, contents: nil, attributes: nil))
        precondition(fm!.fileExistsAtPath(testPath))
        precondition(fm!.isWritableFileAtPath(testPath))

        XCTAssertDoesNotThrow(try DefaultWriter(path: testPath))
    }

    func testMIDIWriter_write__fails_when_handleIs_nil() {

        let testPath = bundle!.resourcePath! + "/tata"

        precondition(fm!.createFileAtPath(testPath, contents: nil, attributes: nil))
        precondition(fm!.fileExistsAtPath(testPath))
        precondition(fm!.isWritableFileAtPath(testPath))

        let writer = try! DefaultWriter(path: testPath)

        writer.handle = nil
        XCTAssertFalse(writer.write(testPath.dataUsingEncoding(NSUTF8StringEncoding)!))
    }

    func testMIDIWriter_write__succeeds_when_handle_isNot_nil() {

        let testPath = bundle!.resourcePath! + "/tata"

        precondition(fm!.createFileAtPath(testPath, contents: nil, attributes: nil))
        precondition(fm!.fileExistsAtPath(testPath))
        precondition(fm!.isWritableFileAtPath(testPath))

        let writer = try! DefaultWriter(path: testPath)

        XCTAssertTrue(writer.write(testPath.dataUsingEncoding(NSUTF8StringEncoding)!))
    }
}
