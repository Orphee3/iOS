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

    var content: String = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\"><plist version=\"1.0\"><dict><key>AU version</key><real>1</real><key>Instrument</key><dict><key>Layers</key><array><dict><key>Amplifier</key><dict><key>ID</key><integer>0</integer><key>enabled</key><true/></dict><key>Connections</key><array><dict><key>ID</key><integer>0</integer><key>bipolar</key><false/><key>control</key><integer>0</integer><key>destination</key><integer>816840704</integer><key>enabled</key><true/><key>inverse</key><false/><key>scale</key><real>12800</real><key>source</key><integer>300</integer><key>transform</key><integer>1</integer></dict><dict><key>ID</key><integer>1</integer><key>bipolar</key><false/><key>control</key><integer>0</integer><key>destination</key><integer>1343225856</integer><key>enabled</key><true/><key>inverse</key><true/><key>scale</key><real>-96</real><key>source</key><integer>301</integer><key>transform</key><integer>2</integer></dict><dict><key>ID</key><integer>2</integer><key>bipolar</key><false/><key>control</key><integer>0</integer><key>destination</key><integer>1343225856</integer><key>enabled</key><true/><key>inverse</key><true/><key>scale</key><real>-96</real><key>source</key><integer>7</integer><key>transform</key><integer>2</integer></dict><dict><key>ID</key><integer>3</integer><key>bipolar</key><false/><key>control</key><integer>0</integer><key>destination</key><integer>1343225856</integer><key>enabled</key><true/><key>inverse</key><true/><key>scale</key><real>-96</real><key>source</key><integer>11</integer><key>transform</key><integer>2</integer></dict><dict><key>ID</key><integer>4</integer><key>bipolar</key><true/><key>control</key><integer>0</integer><key>destination</key><integer>1344274432</integer><key>enabled</key><true/><key>inverse</key><false/><key>scale</key><real>1</real><key>source</key><integer>10</integer><key>transform</key><integer>1</integer></dict><dict><key>ID</key><integer>7</integer><key>bipolar</key><true/><key>control</key><integer>241</integer><key>destination</key><integer>816840704</integer><key>enabled</key><true/><key>inverse</key><false/><key>scale</key><real>12800</real><key>source</key><integer>224</integer><key>transform</key><integer>1</integer></dict><dict><key>ID</key><integer>6</integer><key>bipolar</key><true/><key>control</key><integer>1</integer><key>destination</key><integer>816840704</integer><key>enabled</key><true/><key>inverse</key><false/><key>scale</key><real>200</real><key>source</key><integer>268435456</integer><key>transform</key><integer>1</integer></dict><dict><key>ID</key><integer>5</integer><key>bipolar</key><false/><key>control</key><integer>0</integer><key>destination</key><integer>1343225856</integer><key>enabled</key><true/><key>inverse</key><true/><key>scale</key><real>-96</real><key>source</key><integer>536870912</integer><key>transform</key><integer>1</integer></dict></array><key>Envelopes</key><array><dict><key>ID</key><integer>0</integer><key>Stages</key><array><dict><key>curve</key><integer>20</integer><key>stage</key><integer>0</integer><key>time</key><real>0</real></dict><dict><key>curve</key><integer>22</integer><key>stage</key><integer>1</integer><key>time</key><real>0</real></dict><dict><key>curve</key><integer>20</integer><key>stage</key><integer>2</integer><key>time</key><real>0</real></dict><dict><key>curve</key><integer>20</integer><key>stage</key><integer>3</integer><key>time</key><real>0</real></dict><dict><key>level</key><real>1</real><key>stage</key><integer>4</integer></dict><dict><key>curve</key><integer>20</integer><key>stage</key><integer>5</integer><key>time</key><real>0.2000000029802322</real></dict><dict><key>curve</key><integer>20</integer><key>stage</key><integer>6</integer><key>time</key><real>0.004999999888241291</real></dict></array><key>enabled</key><true/></dict></array><key>Filters</key><dict><key>ID</key><integer>0</integer><key>cutoff</key><real>10000</real><key>enabled</key><false/><key>resonance</key><real>0</real></dict><key>ID</key><integer>0</integer><key>LFOs</key><array><dict><key>ID</key><integer>0</integer><key>enabled</key><true/></dict></array><key>Oscillator</key><dict><key>ID</key><integer>0</integer><key>enabled</key><true/></dict><key>Zones</key><array><dict><key>ID</key><integer>1</integer><key>enabled</key><true/><key>loop enabled</key><true/><key>loop start</key><integer>152591</integer><key>max key</key><integer>37</integer><key>min key</key><integer>0</integer><key>name</key><string>1a#.caf</string><key>output</key><integer>0</integer><key>root key</key><integer>34</integer><key>waveform</key><integer>1</integer></dict><dict><key>ID</key><integer>2</integer><key>enabled</key><true/><key>loop enabled</key><true/><key>loop start</key><integer>118328</integer><key>max key</key><integer>50</integer><key>min key</key><integer>38</integer><key>name</key><string>2a#.caf</string><key>output</key><integer>0</integer><key>root key</key><integer>46</integer><key>waveform</key><integer>2</integer></dict><dict><key>ID</key><integer>3</integer><key>enabled</key><true/><key>loop enabled</key><true/><key>loop start</key><integer>215956</integer><key>max key</key><integer>61</integer><key>min key</key><integer>51</integer><key>name</key><string>3a#.caf</string><key>output</key><integer>0</integer><key>root key</key><integer>58</integer><key>waveform</key><integer>3</integer></dict><dict><key>ID</key><integer>4</integer><key>enabled</key><true/><key>loop enabled</key><true/><key>loop start</key><integer>167533</integer><key>max key</key><integer>74</integer><key>min key</key><integer>62</integer><key>name</key><string>4g.caf</string><key>output</key><integer>0</integer><key>root key</key><integer>67</integer><key>waveform</key><integer>4</integer></dict><dict><key>ID</key><integer>5</integer><key>enabled</key><true/><key>loop enabled</key><true/><key>loop start</key><integer>175741</integer><key>max key</key><integer>127</integer><key>min key</key><integer>75</integer><key>name</key><string>5e.caf</string><key>output</key><integer>0</integer><key>root key</key><integer>75</integer><key>waveform</key><integer>5</integer></dict></array><key>output</key><integer>0</integer></dict></array><key>name</key><string>Trombone</string><key>output</key><integer>0</integer></dict><key>coarse tune</key><integer>0</integer><key>data</key><data>AAAAAAAAAAAAAAAEAAADhAAAAAAAAAOFAAAAAAAAA4YAAAAAAAADhwAAAAA=</data><key>element-name</key><dict><key>3</key><dict><key>0</key><string>Default Instrument</string></dict></dict><key>file-references</key><dict><key>Sample:1</key><string>Sounds/Tbone/1a#.caf</string><key>Sample:2</key><string>Sounds/Tbone/2a#.caf</string><key>Sample:3</key><string>Sounds/Tbone/3a#.caf</string><key>Sample:4</key><string>Sounds/Tbone/4g.caf</string><key>Sample:5</key><string>Sounds/Tbone/5e.caf</string></dict><key>fine tune</key><integer>0</integer><key>gain</key><real>0</real><key>manufacturer</key><integer>1634758764</integer><key>name</key><string>Trombone</string><key>output</key><integer>0</integer><key>pan</key><real>0</real><key>subtype</key><integer>1935764848</integer><key>type</key><integer>1635085685</integer><key>version</key><integer>0</integer><key>voice count</key><integer>64</integer></dict></plist>";

    var mgr: PresetMgr! = nil;
    var path: String? = NSBundle.mainBundle().pathForResource("Trombone", ofType: "aupreset");
    lazy var url: NSURL? = ({
        //FIXME: Possible strong reference cycle?
        if let PATH = self.path {
            println("\n\nPATH = \(self.path)\n\n");
            return NSURL(fileURLWithPath: PATH);
        }
        return nil;
    })();
    lazy var validData: CFDataRef? = self.content.dataUsingEncoding(4, allowLossyConversion: false);
    lazy var validPlist: NSDictionary? = NSDictionary(contentsOfFile: self.path!);


    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        mgr = PresetMgr();
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testIfFileExists() {

        XCTAssertNotNil(path, "ERROR creating ressource file's path");
        XCTAssertNotNil(url, "ERROR creating ressource file's URL");
    }


    //////////////////////////////////
    // getDataFromRessourceWithPath //
    //////////////////////////////////

    func testThat_getDataFromRessourceWithPath_succeeds_whenGiven_reachableFile() {

        var result: (data: CFDataRef?, error: NSError?) = mgr.getDataFromRessourceWithPath(path!);

        XCTAssertNil(result.error, "\nERROR: \(result.error)\n");
        XCTAssertNotNil(result.data, "\nERROR: no data was read from file");
    }

    func testThat_getDataFromRessourceWithPath_fails_whenGiven_InvalidPath() {

        var result: (data: CFDataRef?, error: NSError?) = mgr.getDataFromRessourceWithPath("");

        XCTAssertNotNil(result.error, "\nERROR: The test did not fail as was expected\n");
        XCTAssertNil(result.data, "\nData was read:\n\(result.data)\n");
        println("\nGot error: \(result.error)\n");
    }

    func testThat_getDataFromRessourceWithPath_fails_whenGiven_directory() {

        var result: (data: CFDataRef?, error: NSError?) = mgr.getDataFromRessourceWithPath("\(NSBundle.mainBundle().resourcePath!)/Sounds/");

        XCTAssertNotNil(result.error, "\nERROR: The test did not fail as was expected\n");
        XCTAssertNil(result.data, "\nData was read:\n\(result.data)\n");
        println("\nGot error: \(result.error)\n");
    }


    //////////////////////////////////
    ////// getPlistFromRawData ///////
    //////////////////////////////////

    func testThat_getPlistFromRawData_succeeds_whenGiven_validRawData() {

        var res: (plist: CFPropertyListRef?, error: NSError?) = mgr.getPListFromRawData(validData!);

        XCTAssertNil(res.error, "\nERROR: \(res.error)");
        XCTAssertNotNil(res.plist, "\nERROR: no data was read from file");
        XCTAssert(CFPropertyListIsValid(res.plist!, CFPropertyListFormat.BinaryFormat_v1_0) == 1, "\nERROR: PList is invalid");
        XCTAssertEqual(res.plist as NSDictionary, validPlist!, "ERROR PList is not the same as dictionary");
    }

    func testThat_getPlistFromRawData_fails_whenGiven_rawDataFromAnInvalidFile() {

        var result: (data:CFDataRef?, error:NSError?) = mgr.getDataFromRessourceWithPath(NSBundle.mainBundle().pathForResource("Sounds/Tbone/5e", ofType: "caf")!);

        XCTAssertNil(result.error, "\nERROR: \n\(result.error)\n");
        XCTAssertNotNil(result.data, "\nERROR: no data obtained");

        var res: (plist: CFPropertyListRef?, error: NSError?) = mgr.getPListFromRawData(result.data!);

        XCTAssertNotNil(res.error, "\nERROR: The test did not fail as was expected\n");
        XCTAssertNil(res.plist, "\nA Plist was obtained:\n\(res.plist)\n");
        println("\nGot error: \(res.error)\n");
    }


    ///////////////////////////////////
    // getPlistFromRessourceWithPath //
    ///////////////////////////////////

    func testThat_getPlistFromRessourceWithPath_succeeds_whenGiven_reachableFile() {

        var result: (plist: CFPropertyListRef?, error: NSError?) = mgr.getPlistFromRessourceWithPath(path!);

        XCTAssertNil(result.error, "\nERROR: \(result.error)\n");
        XCTAssertNotNil(result.plist, "\nERROR: no Plist was obtained");
    }

    func testThat_getPlistFromRessourceWithPath_fails_whenGiven_InvalidPath() {

        var result: (plist: CFPropertyListRef?, error: NSError?) = mgr.getPlistFromRessourceWithPath("");

        XCTAssertNotNil(result.error, "\nERROR: The test did not fail as was expected\n");
        XCTAssertNil(result.plist, "\nPlist was obtained:\n\(result.plist)\n");
        println("\nGot error: \(result.error)\n");
    }

    func testThat_getPlistFromRessourceWithPath_fails_whenGiven_directory() {

        var result: (plist: CFPropertyListRef?, error: NSError?) = mgr.getPlistFromRessourceWithPath("\(NSBundle.mainBundle().resourcePath!)/Sounds/");

        XCTAssertNotNil(result.error, "\nERROR: The test did not fail as was expected\n");
        XCTAssertNil(result.plist, "\nPlist was obtained:\n\(result.plist)\n");
        println("\nGot error: \(result.error)\n");
    }
}
