//
//  CoreMIDISequenceCreatorTests.swift
//  FileManagement
//
//  Created by JohnBob on 14/07/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit
import XCTest
import AudioToolbox

@testable import MIDIToolbox


/** CoreMIDISequenceCreatorTests Class

*/
class CoreMIDISequenceCreatorTests : XCTestCase {

    var cmsCreator: CoreMIDISequenceCreator!;

    override func setUp() {
        super.setUp()
        // Put Setup code here. This method is called before the invocation of each test method in the class.

        self.cmsCreator = CoreMIDISequenceCreator(trkNbr: 1, ppqn: 384);
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test_makeMIDIBuffer_providesCorrectData() {

        let buffer: MusicSequence = CoreMIDISequenceCreator.makeMIDIBuffer();

        XCTAssertEqual(getTimeResolution(buffer), 480);
        XCTAssertEqual(getTracksCount(buffer), 0);
    }

    func test_setupMIDIBuffer_succeeds() {

        let buffer: MusicSequence = CoreMIDISequenceCreator.makeMIDIBuffer();
        cmsCreator.buildMIDIBuffer();

        XCTAssertEqual(getTracksCount(buffer), getTracksCount(cmsCreator.buffer), "Track count !");
        XCTAssertEqual(getTimeResolution(buffer), getTimeResolution(cmsCreator.buffer), "TIME RES !");
    }

    func test_buildNoteEvent_createsCorrectNoteMsg() {

        //let event: MIDINoteMessage = MIDINoteMessage
    }
}

func getTimeResolution(s: MusicSequence) -> UInt32 {

    var t: MusicTrack = MusicTrack();
    var len: UInt32 = 0;
    var ppqn: UInt32 = 0;

    MusicSequenceGetTempoTrack(s, &t);
    MusicTrackGetProperty(t, UInt32(kSequenceTrackProperty_TimeResolution), UnsafeMutablePointer<Void>(bitPattern: 0), &len);
    MusicTrackGetProperty(t, UInt32(kSequenceTrackProperty_TimeResolution), &ppqn, &len);
    print("\(s)'s PPQN: \(ppqn)");
    return ppqn;
}

func getTracksCount(s: MusicSequence) -> UInt32 {

    var trackCount: UInt32 = 0;

    MusicSequenceGetTrackCount(s, &trackCount);
    print("\(s)'s Nbr of trks: \(trackCount)");
    return trackCount;
}