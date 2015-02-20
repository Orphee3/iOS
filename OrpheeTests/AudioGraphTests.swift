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

        //FIXME: For some reason CAShow encounters an error
        //        CAShow(&graph.graph);

        var resData = pstMgr.getDataFromRessourceWithPath(path!);
        XCTAssertNil(resData.error, "Couldn't load raw data from file:\n\(resData.error)\n");
        var resPlist = pstMgr.getPListFromRawData(resData.data!);
        XCTAssertNil(resPlist.error, "Couldn't load PList from raw data:\n\(resPlist.error)\n");
        XCTAssert(graph.loadPresetFromPList(&resPlist.plist!) == noErr, "Preset LOADING failed for file:\n\(path)\n");
    }

    func testIfAudioOutputWorks_fromPreset_Swift() {

        graph.createAudioGraph();
        graph.configureAudioGraph();
        graph.startAudioGraph();
        var pstMgr: PresetMgr = PresetMgr();

        self.measureBlock() {

            var resData = pstMgr.getDataFromRessourceWithPath(self.path!);

            XCTAssertNil(resData.error, "Couldn't load raw data from file:\n\(resData.error)\n");

            var resPlist = pstMgr.getPListFromRawData(resData.data!);

            XCTAssertNil(resPlist.error, "Couldn't load PList from raw data:\n\(resPlist.error)\n");
            XCTAssert(self.graph.loadPresetFromPList(&resPlist.plist!) == noErr, "Preset LOADING failed for file:\n\(self.path)\n");
        };

        XCTAssert(graph.playNote(48) == noErr, "Couldn't PLAY note");
        sleep(1);
        XCTAssert(graph.stopNote(48) == noErr, "Couldn't STOP playing note");
    }

    func testIfAudioOutputWorks_fromPreset_ObjC() {

        graph.createAudioGraph();
        graph.configureAudioGraph();
        graph.startAudioGraph();
        var pstMgr: PresetMgr = PresetMgr();

        self.measureBlock() {

            var url1: NSURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Vibraphone", ofType: "aupreset")!)!;

            XCTAssert(pstMgr.loadPresetFromURL(url1, graphMgr: self.graph));
        };

        XCTAssert(graph.playNote(48) == noErr, "Couldn't PLAY note");
        sleep(1);
        XCTAssert(graph.stopNote(48) == noErr, "Couldn't STOP playing note");
    }

    func testIfAudioOuputWorks_fromSoundBank_ObjC() {

        graph.createAudioGraph();
        graph.configureAudioGraph();
        graph.startAudioGraph();
        var pstMgr: PresetMgr = PresetMgr();

        self.measureBlock() {

            var url: NSURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("SoundBanks/ProTrax_Classical_Guitar", ofType: "sf2")!)!;

            XCTAssert(pstMgr.loadSoundBankFromURL(url, patchId: 0, graphMgr: self.graph));
        };

        XCTAssert(graph.playNote(48) == noErr, "Couldn't PLAY note");
        sleep(1);
        XCTAssert(graph.stopNote(48) == noErr, "Couldn't STOP playing note");
    }

    func testIfAudioOuputWorks_fromMelodicSoundBank_Swift() {

        graph.createAudioGraph();
        graph.configureAudioGraph();
        graph.startAudioGraph();
        var pstMgr: PresetMgr = PresetMgr();
        var path: String = NSBundle.mainBundle().pathForResource("SoundBanks/ProTrax_Classical_Guitar", ofType: "sf2")!;

        self.measureBlock() {

            var resInstru = pstMgr.getMelodicInstrumentFromSoundBank(path: path);

            XCTAssert(resInstru != nil, "Couldn't load instrument from file \(path)\n");
            if (resInstru != nil) {
                XCTAssert(self.graph.loadInstrumentFromInstrumentData(&resInstru!) == noErr, "Instrument LOADING failed for file:\n\(path)\n");
            }
            else {
                XCTAssertFalse(false, "No instrument to load");
            }
        };

        XCTAssert(graph.playNote(48) == noErr, "Couldn't PLAY note");
        sleep(1);
        XCTAssert(graph.stopNote(48) == noErr, "Couldn't STOP playing note");
    }

    func testIfAudioOuputWorks_fromPercussionSoundBank_Swift() {

        graph.createAudioGraph();
        graph.configureAudioGraph();
        graph.startAudioGraph();
        var pstMgr: PresetMgr = PresetMgr();
        var path: String = NSBundle.mainBundle().pathForResource("SoundBanks/Roland_TD10_Woody", ofType: "sf2")!;

        self.measureBlock() {

            var resInstru = pstMgr.getPercussionInstrumentFromSoundBank(id: 1, path: path);

            XCTAssert(resInstru != nil, "\n\nCouldn't load instrument from file \(path)\n");
            if (resInstru != nil) {
                XCTAssert(self.graph.loadInstrumentFromInstrumentData(&resInstru!) == noErr, "\n\nInstrument LOADING failed for file:\n\(path)\n");
            }
            else {
                XCTAssertFalse(false, "No instrument to load");
            }
        };

        XCTAssert(graph.playNote(48) == noErr, "Couldn't PLAY note");
        sleep(1);
        XCTAssert(graph.stopNote(48) == noErr, "Couldn't STOP playing note");
    }

}
