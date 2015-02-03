//
//  AudioGraphTests.swift
//  Orphee
//
//  Created by John Bob on 29/01/15.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit
import XCTest
import AVFoundation

class AudioGraphCreationSubroutinesTests: XCTestCase {

    var result: OSStatus = noErr;
    var graph: AudioGraph! = nil;

    override func setUp() {

        super.setUp();

        graph = AudioGraph();

        result = noErr;
        result = NewAUGraph(&graph.graph!);
        assert(result == noErr, "An error occured at setup");
    }

    override func tearDown() {

        graph = nil;

        super.tearDown();
    }

    func testForErrorsWhileBuildingSamplerNode() {

        var sampler = AUNode();

        result = graph.buildSamplerNode(&sampler);
        XCTAssert(result == noErr, "Error occured while building sampler Node");
    }

    func testForErrorsWhileBuildingOutputNode() {

        var out = AUNode();

        result = graph.buildSamplerNode(&out);
        XCTAssert(result == noErr, "Error occured while building output Node");
    }

    func testMakingAudioComponentDescription() {

        var ac: AudioComponentDescription = graph.mkComponentDescription();

        XCTAssert(ac.componentType == OSType(0), "Incorrect Type");
        XCTAssert(ac.componentSubType == OSType(0), "Incorrect SubType");
        XCTAssert(ac.componentManufacturer == OSType(kAudioUnitManufacturer_Apple), "Incorrect Manufacturer");
        XCTAssert(ac.componentFlags == 0, "Incorrect Flags");
        XCTAssert(ac.componentFlagsMask == 0, "Incorrect Mask for Component Flags");

        ac = graph.mkComponentDescription(type: OSType(kAudioUnitType_MusicDevice), subType: OSType(kAudioUnitSubType_Sampler));

        XCTAssert(ac.componentType == OSType(kAudioUnitType_MusicDevice), "Incorrect Type");
        XCTAssert(ac.componentSubType == OSType(kAudioUnitSubType_Sampler), "Incorrect SubType");
        XCTAssert(ac.componentManufacturer == OSType(kAudioUnitManufacturer_Apple), "Incorrect Manufacturer");
        XCTAssert(ac.componentFlags == 0, "Incorrect Flags");
        XCTAssert(ac.componentFlagsMask == 0, "Incorrect Mask for Component Flags");

        ac = graph.mkComponentDescription(type: OSType(kAudioUnitType_Output), subType: OSType(kAudioUnitSubType_RemoteIO));

        XCTAssert(ac.componentType == OSType(kAudioUnitType_Output), "Incorrect Type");
        XCTAssert(ac.componentSubType == OSType(kAudioUnitSubType_RemoteIO), "Incorrect SubType");
        XCTAssert(ac.componentManufacturer == OSType(kAudioUnitManufacturer_Apple), "Incorrect Manufacturer");
        XCTAssert(ac.componentFlags == 0, "Incorrect Flags");
        XCTAssert(ac.componentFlagsMask == 0, "Incorrect Mask for Component Flags");
    }
    
}

class AudioGraphTests: XCTestCase {

    var graph: AudioGraph! = nil;
    var session: AudioSession! = nil;
    var path: String? = NSBundle.mainBundle().pathForResource("Trombone", ofType: "aupreset");

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        session = AudioSession();
        graph = AudioGraph();
        XCTAssert(session.setupSession(&graph!), "Error while setting up session");
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        graph = nil;

        super.tearDown()
    }

    func testIfCreateGraphProperlyConstructsGraph() {

        let result = graph.createAudioGraph();
        if let test = graph.graph {
            XCTAssertTrue(true, "All good");
        }
        else {
            XCTAssert(false, "Audio graph is Nil");
        }

        if let test = graph.ioUnit {
            XCTAssertTrue(true, "All good");
        }
        else {
            XCTAssert(false, "Audio graph output unit is Nil");
        }
        if let test = graph.sampler {
            XCTAssertTrue(true, "All good");
        }
        else {
            XCTAssert(false, "Audio graph sampler unit is Nil");
        }
        XCTAssertTrue(result, "Error on Audio graph CREATION");
    }

    func testIfConfigureGraphProperlyConfiguresGraph() {

        var result = graph.createAudioGraph();

        XCTAssertTrue(result, "Error on Audio graph CREATION");
        
        result = graph.configureAudioGraph();
        XCTAssertTrue(result, "Error on Audio graph CONFIGURATION");
    }

    func testIfStartGraphDoesItsJob() {

        var result = graph.createAudioGraph();

        XCTAssertTrue(result, "Error on Audio graph CREATION");

        result = graph.configureAudioGraph();
        XCTAssertTrue(result, "Error on Audio graph CONFIGURATION");

        result = graph.startAudioGraph();
        XCTAssertTrue(result, "Error on Audio graph START");

        var test: Boolean = 0;
        result = AUGraphIsInitialized(graph.graph!, &test) == noErr;
        XCTAssert(test == 1, "Graph wasn't initialized");

        test = 0;
        result = AUGraphIsRunning(graph.graph!, &test) == noErr;
        XCTAssert(test == 1, "Graph isn't running");
    }

    func testIfPresetSettingOnSamplerWorks() {

        graph.createAudioGraph();
        graph.configureAudioGraph();
        graph.startAudioGraph();
        var pstMgr: PresetMgr = PresetMgr();

        var plist: CFPropertyListRef = pstMgr.getPListFromRessourceForURL(NSURL(fileURLWithPath: path!)!)!;
        XCTAssert(graph.loadPresetFromPList(&plist) == noErr, "Preset LOADING failed for file:\n\(path)\n");
    }

    func testIfAudioOuputWorks() {

        graph.createAudioGraph();
        graph.configureAudioGraph();
        graph.startAudioGraph();
        var pstMgr: PresetMgr = PresetMgr();

        //        var res = pstMgr.loadPresetFromURL(NSURL(fileURLWithPath: path!)!, graphMgr: graph);

        var plist: CFPropertyListRef = pstMgr.getPListFromRessourceForURL(NSURL(fileURLWithPath: path!)!)!;
        graph.loadPresetFromPList(&plist)

        XCTAssert(graph.playNote(48) == noErr, "Couldn't PLAY note");
        sleep(1);
        XCTAssert(graph.stopNote(48) == noErr, "Couldn't STOP playing note");
    }
}
