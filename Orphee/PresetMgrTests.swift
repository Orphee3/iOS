//
//  PresetMgrTests.swift
//  Orphee
//
//  Created by John Bob on 03/02/15.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit
import XCTest

class PresetMgrTests: XCTestCase {

    var mgr: PresetMgr! = nil;
    var path: String? = NSBundle.mainBundle().pathForResource("Trombone", ofType: "aupreset");
    var url: NSURL? = nil;

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        if let PATH = path {
            url = NSURL(fileURLWithPath: PATH);
        }
        else {
            XCTAssertFalse(false, "\(path) No such File");
        }
        mgr = PresetMgr();
    }
    	
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testIfFileExists() {

        XCTAssertNotNil(url, "ERROR loading Preset file");
    }

    func testIfRessourceDataHasBeenFilled() {

        var data: CFDataRef? = mgr.getDataFromRessourceForURL(url!);
        var plist: CFPropertyListRef? = mgr.getPListFromRessourceForURL(url!);

        XCTAssertNotNil(data, "ERROR: Couldn't READ DATA from file");
        XCTAssertNotNil(plist, "ERROR: Couldn't CREATE PLIST from data");
    }

}
