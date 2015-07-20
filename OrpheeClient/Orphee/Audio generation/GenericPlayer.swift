//
//  GenericPlayer.swift
//  Orphee
//
//  Created by JohnBob on 12/07/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation

class GenericPlayer: pAudioPlayer {

    weak var session: AudioSession?;
    weak var audioGraph: AudioGraph?;
    var player: MusicPlayer = MusicPlayer();
    var sequence: MusicSequence = MusicSequence();
    var currentTime: MusicTimeStamp = 0;

    required init(graph: AudioGraph, session: AudioSession) {

        self.audioGraph = graph;
        self.session = session;
        NewMusicPlayer(&self.player);
        NewMusicSequence(&self.sequence);
        MusicSequenceSetAUGraph(self.sequence, graph.graph);
    }

    func play() {

        MusicSequenceFileLoad(sequence, NSURL.fileURLWithPath("/Users/Massil/Desktop/test.mid"), 0, 0);
        MusicPlayerSetSequence(player, sequence);
        MusicPlayerPreroll(player);
        MusicPlayerStart(player);
    }

    // Doesn't allow for resume option.
    func pause() {

        var state = MusicPlayerGetTime(player, &currentTime);
        MusicPlayerStop(player);
    }

    func stop() {

        let state = MusicPlayerStop(player);
        if (state != noErr) {
            clean();
            NewMusicSequence(&sequence);
            println("\(NSError(domain: NSOSStatusErrorDomain, code: Int(state), userInfo: nil))");
        }
    }

    func isPlaying() -> Bool {

        var playing: Boolean = 0;

        let state = MusicPlayerIsPlaying(player, &playing);
        if (state != noErr) {
            playing = 0;
            stop();
            clean();
            NewMusicSequence(&sequence);
            println("\(NSError(domain: NSOSStatusErrorDomain, code: Int(state), userInfo: nil))");
        }
        return playing == 1;
    }

    func clean() {

        DisposeMusicSequence(sequence)
    }

    deinit {

        clean();
        DisposeMusicPlayer(player);
        session = nil;
        audioGraph = nil;
    }
}
