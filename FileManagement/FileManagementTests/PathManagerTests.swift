//
//  PathManagerTests.swift
//  FileManagement
//
//  Created by JohnBob on 10/09/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import UIKit
import XCTest

@testable import FileManagement

/** PathManagerTests Class

*/
class PathManagerTests : XCTestCase {

    func testListFiles_throws__when_pathIs_emptyString() {
        XCTAssertThrows(try PathManager.listFiles(""))
    }

    func testListFiles_returns_expectedList__when_pathIs_valid__and_noExtension_isSpecified() {
        let entries = try! PathManager.listFiles(kOrpheeFile_store);
        XCTAssertEqual(entries, ["test.mid", "test2.mid", "test3.midi"]);
        entries.forEach() { print($0) }
    }

    func testListFiles_returns_expectedList__when_pathIs_valid__and_extension_isSpecified() {
        let entries = try! PathManager.listFiles(kOrpheeFile_store, fileExtension: kOrpheeFile_extension);
        XCTAssertEqual(entries, ["test.mid", "test2.mid"]);
        entries.forEach() { print($0) }
    }

    // MARK: - Setup
    override func setUp() {
        super.setUp()
        // Put Setup code here. This method is called before the invocation of each test method in the class.

        try! NSFileManager.defaultManager().createDirectoryAtPath(kOrpheeFile_store, withIntermediateDirectories: true, attributes: nil);
        NSFileManager.defaultManager().createFileAtPath(kOrpheeFile_store + "/test.mid", contents: nil, attributes: nil);
        NSFileManager.defaultManager().createFileAtPath(kOrpheeFile_store + "/test2.mid", contents: nil, attributes: nil);
        NSFileManager.defaultManager().createFileAtPath(kOrpheeFile_store + "/test3.midi", contents: nil, attributes: nil);
    }

    override func tearDown() {
//        try! NSFileManager.defaultManager().removeItemAtPath(kOrpheeFile_store);
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
}
