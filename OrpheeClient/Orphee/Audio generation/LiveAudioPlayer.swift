//
// Created by JohnBob on 16/08/15.
// Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import FileManagement

final class LiveAudioPlayer: pAudioPlayerWithDataSource {

    typealias audioDataType = [[Int]];
    var audioData: audioDataType;

    var session: AudioSession?;
    var audioGraph: AudioGraph?;
    dynamic var playing: Bool = false;
    dynamic var lastPos: Int = 0;

    var queue: dispatch_queue_t;

    internal init(graph: AudioGraph, session: AudioSession) {
        self.session = session;
        self.audioGraph = graph;
        self.audioData = [];
        self.queue = dispatch_queue_create("toto", DISPATCH_QUEUE_CONCURRENT);
    }

    convenience init(graph: AudioGraph, session: AudioSession, audioData: audioDataType) {

        self.init(graph: graph, session: session);
        self.audioData = audioData;
    }

    ///  Do NOT use. Present for protocol conformance only.
    ///
    ///  - parameter data: Unused data
    func play(data: NSData) {
    }

    func play() {

        playing = true;
        let dataToRead = audioDataType(self.audioData[lastPos..<self.audioData.endIndex]);
        dispatch_async(queue, { self.playAudioData(dataToRead); })
    }

    func pause() {

        playing = false;
    }

    func stop() {

        playing = false;
        lastPos = 0;
    }
    
    func clean() {
    }

    private func playAudioData(dataToRead: audioDataType) {

        var paused = false;

        noteEvents:
            for (idx, dtNotes) in dataToRead.enumerate() where self.playing == true {
                self.lastPos = idx;
                self.playNotes(dtNotes, noteLength: eNoteLength.crotchet);
                if (!self.playing) {
                    paused = true;
                    break noteEvents;
                }
        }
        if (!paused) {
            self.stop();
        }
    }

    private func scheduleNoteOns(dtNotes: [Int]) {

        for note in dtNotes {
            self.audioGraph!.playNote(UInt32(note));
        }
    }

    private func scheduleNoteOffs(dtNotes: [Int]) {

        for note in dtNotes {
            self.audioGraph!.stopNote(UInt32(note));
        }
    }

    private func playNotes(notes: [Int], noteLength length: eNoteLength) {

        self.scheduleNoteOns(notes);
        usleep(useconds_t(length.rawValue * 1_000_000));
        self.scheduleNoteOffs(notes);
    }
}
