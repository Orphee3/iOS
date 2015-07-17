//
//  GenericPlayer.swift
//  Orphee
//
//  Created by JohnBob on 12/07/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation

class GenericPlayer: AudioPlayer {

    weak var session: AudioSession?;
    weak var audioGraph: AudioGraph?;
    var player: MusicPlayer = MusicPlayer();
    var sequence: MusicSequence = MusicSequence();

    required init(graph: AudioGraph, session: AudioSession) {

        self.audioGraph = graph;
        self.session = session;
        NewMusicPlayer(&self.player);
        NewMusicSequence(&self.sequence);
    }

    func play() {

        MusicSequenceFileLoad(sequence, NSURL.fileURLWithPath("/Users/Massil/Desktop/test.midi"), 0, 0);
        MusicPlayerSetSequence(player, sequence);
        MusicPlayerPreroll(player);
        MusicPlayerStart(player);
    }

    // Doesn't allow for resume option.
    func pause() {

        MusicPlayerStop(player);
    }

    func stop() {

        MusicPlayerStop(player);
        clean();
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