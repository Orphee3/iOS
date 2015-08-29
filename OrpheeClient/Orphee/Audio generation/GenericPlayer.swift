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
        var st: OSStatus = NewMusicPlayer(&self.player);
        assert(st == noErr, "\(NSError(domain: NSOSStatusErrorDomain, code: Int(st), userInfo: nil))");
        st = NewMusicSequence(&self.sequence);
        assert(st == noErr, "\(NSError(domain: NSOSStatusErrorDomain, code: Int(st), userInfo: nil))");
        st = MusicSequenceSetAUGraph(self.sequence, graph.graph);
        assert(st == noErr, "\(NSError(domain: NSOSStatusErrorDomain, code: Int(st), userInfo: nil))");
    }

    func play() {

        var st: OSStatus = MusicSequenceFileLoad(sequence, NSURL(fileURLWithPath: "/Users/Massil/Desktop/test.mid"), MusicSequenceFileTypeID(rawValue: 0)!, MusicSequenceLoadFlags(rawValue: 0));
        assert(st == noErr, "\(NSError(domain: NSOSStatusErrorDomain, code: Int(st), userInfo: nil))");
        st = MusicPlayerSetSequence(player, sequence);
        assert(st == noErr, "\(NSError(domain: NSOSStatusErrorDomain, code: Int(st), userInfo: nil))");
        st = MusicPlayerPreroll(player);
        assert(st == noErr, "\(NSError(domain: NSOSStatusErrorDomain, code: Int(st), userInfo: nil))");
        st = MusicPlayerStart(player);
        assert(st == noErr, "\(NSError(domain: NSOSStatusErrorDomain, code: Int(st), userInfo: nil))");
    }

    // Doesn't allow for resume option.
    func pause() {

        var st: OSStatus = MusicPlayerGetTime(player, &currentTime);
        assert(st == noErr, "\(NSError(domain: NSOSStatusErrorDomain, code: Int(st), userInfo: nil))");
        st = MusicPlayerStop(player);
        assert(st == noErr, "\(NSError(domain: NSOSStatusErrorDomain, code: Int(st), userInfo: nil))");
    }

    func stop() {

        let state = MusicPlayerStop(player);
        if (state != noErr) {
            clean();
            NewMusicSequence(&sequence);
            print("\(NSError(domain: NSOSStatusErrorDomain, code: Int(state), userInfo: nil))", appendNewline: false);
        }
    }

    func isPlaying() -> Bool {

        var playing: DarwinBoolean = false;

        let state = MusicPlayerIsPlaying(player, &playing);
        if (state != noErr) {
            playing = false;
            stop();
            clean();
            NewMusicSequence(&sequence);
            print("\(NSError(domain: NSOSStatusErrorDomain, code: Int(state), userInfo: nil))", appendNewline: false);
        }
        return playing == true;
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
