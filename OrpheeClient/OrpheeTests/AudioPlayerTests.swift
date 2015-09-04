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

class AudioPlayerTests: XCTestCase {

    var player: pAudioPlayer!;
    var graph: AudioGraph!;
    var session: AudioSession!;

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
        player.play();
        XCTAssert(player.playing, "not playing.")
        sleep(3);
        player.pause();
        XCTAssert(!player.playing, "not playing.")
        sleep(1);
        player.play();
        XCTAssert(player.playing, "not playing.")
        sleep(1);
        player.stop();
        XCTAssert(!player.playing, "not playing.")
    }
}
