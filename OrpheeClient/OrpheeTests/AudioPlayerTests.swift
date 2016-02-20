//
//  pAudioPlayer.swift
//  Orphee
//
//  Created by JohnBob on 12/07/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit
import XCTest
import AVFoundation
import FileManagement
import MIDIToolbox

@testable import Orphee

class AudioPlayerTests: XCTestCase {

    var player: pAudioPlayer!;
    var graph: AudioGraph!;
    var session: AudioSession!;

    let data: NSData = NSData(contentsOfFile: NSBundle(forClass: AudioPlayerTests.self).pathForResource("Dont_Cry", ofType: ".mid")!)!;

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        session = AudioSession();
        graph = AudioGraph();
        session!.setupSession(&(graph!));
        graph!.createAudioGraph();
        graph!.configureAudioGraph();
        graph!.startAudioGraph();
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()

        graph = nil;
        session = nil;
    }

    func testAll() {

        player = GenericPlayer(graph: graph!, session: session!);
        player.play(data);
        XCTAssert(player.playing, "not playing.")
        sleep(5);
        player.pause();
        XCTAssert(!player.playing, "not playing.")
        sleep(1);
        player.play(data);
        XCTAssert(player.playing, "not playing.")
        sleep(1);
        player.stop();
        XCTAssert(!player.playing, "not playing.")
    }

    func testLivePlayer() {

        let reader = DefaultReader(path: NSBundle(forClass: AudioPlayerTests.self).pathForResource("xtreme", ofType: "mid")!)
        let dat = reader.readAllData();
        let parser = MIDIDataParser(data: dat);
        let pl = LiveAudioPlayer(graph: graph, session: session, audioData: parser.parseTracks()[2]!);
        pl.play();
        sleep(5)
    }
}
