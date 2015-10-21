//
//  GenericPlayer.swift
//  Orphee
//
//  Created by JohnBob on 12/07/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation

struct GenericPlayer: pAudioPlayer {

    weak var session: AudioSession?;
    weak var audioGraph: AudioGraph?;

    var player: MusicPlayer = MusicPlayer();
    var sequence: MusicSequence = MusicSequence();

    var currentTime: MusicTimeStamp = 0;

    var playing: Bool {
        get {
            var playing: DarwinBoolean = false;

            MusicPlayerIsPlaying(player, &playing);
            return playing == true;
        }
        set {
            playing = newValue;
        }
    }

    init(graph: AudioGraph, session: AudioSession) {

        self.audioGraph = graph;
        self.session = session;
        var st: OSStatus = NewMusicPlayer(&self.player);
        assert(st == noErr, "\(NSError(domain: NSOSStatusErrorDomain, code: Int(st), userInfo: nil))");
        st = NewMusicSequence(&self.sequence);
        assert(st == noErr, "\(NSError(domain: NSOSStatusErrorDomain, code: Int(st), userInfo: nil))");
        st = MusicSequenceSetAUGraph(self.sequence, graph.graph);
        assert(st == noErr, "\(NSError(domain: NSOSStatusErrorDomain, code: Int(st), userInfo: nil))");
    }

    func play(data: NSData) {
        MusicPlayerStop(player)
        var st: OSStatus = MusicSequenceFileLoadData(sequence, data, MusicSequenceFileTypeID.MIDIType, MusicSequenceLoadFlags.SMF_PreserveTracks);
        assert(st == noErr, "Got \(data.length) bytes\n\(NSError(domain: NSOSStatusErrorDomain, code: Int(st), userInfo: nil))");
        st = MusicPlayerSetSequence(player, sequence);
        assert(st == noErr, "\(NSError(domain: NSOSStatusErrorDomain, code: Int(st), userInfo: nil))");
        st = MusicPlayerPreroll(player);
        assert(st == noErr, "\(NSError(domain: NSOSStatusErrorDomain, code: Int(st), userInfo: nil))");
        st = MusicPlayerStart(player);
        assert(st == noErr, "\(NSError(domain: NSOSStatusErrorDomain, code: Int(st), userInfo: nil))");
    }

    // Doesn't allow for resume option.
    mutating func pause() {

        var st: OSStatus = MusicPlayerGetTime(player, &currentTime);
        assert(st == noErr, "\(NSError(domain: NSOSStatusErrorDomain, code: Int(st), userInfo: nil))");
        st = MusicPlayerStop(player);
        assert(st == noErr, "\(NSError(domain: NSOSStatusErrorDomain, code: Int(st), userInfo: nil))");
    }

    mutating func stop() {

        let state = MusicPlayerStop(player);
        if (state != noErr) {
            clean();
            NewMusicSequence(&sequence);
            print("\(NSError(domain: NSOSStatusErrorDomain, code: Int(state), userInfo: nil))", terminator: "");
        }
    }

    func clean() {

        DisposeMusicSequence(sequence)
    }
}
