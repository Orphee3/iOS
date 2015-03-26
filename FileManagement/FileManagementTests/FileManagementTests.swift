//
//  FileManagementTests.swift
//  FileManagementTests
//
//  Created by JohnBob on 21/03/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit
import XCTest

class FileManagementTests: XCTestCase {

    var fm: FormattedFileManager? = nil;

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        fm = MIDIFileManager(name: "test");
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssertNotNil(fm as MIDIFileManager, "File manager is nil");
        XCTAssertTrue(fm!.createFile(nil, header: nil), "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
