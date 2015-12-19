//
// Created by John Bobington on 18/12/2015.
// Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import AVFoundation

public class AudioSequencerManager {
    var sequencer: AVAudioSequencer

    public init(engine: AVAudioEngine) {
        sequencer = AVAudioSequencer(audioEngine: engine)
    }

    public func loadFile(path: String) -> Bool {
        guard let data = NSData(contentsOfFile: path) else {
            return false
        }
        return loadFile(data)
    }

    public func loadFile(data: NSData) -> Bool {
        guard data.length > 0 else {
            return false
        }
        do {
            try sequencer.loadFromData(data, options: AVMusicSequenceLoadOptions.SMF_PreserveTracks)
        }
        catch {
            print("LOADFILE: \(error)");
            return false
        }
        return true
    }

    public func setDestinationAudioUnit(units: [AVAudioUnit]) {
        guard units.count > 0 else { return }
        for (idx, track) in sequencer.tracks.enumerate() where track.lengthInSeconds > 0 {
            track.destinationAudioUnit = units[idx]
        }
    }

    public func play() {
        do {
            sequencer.prepareToPlay()
            try sequencer.start()
        }
        catch {
            debugPrint(error)
        }
    }

    public func getSequenceDuration() -> NSTimeInterval {

        var length: NSTimeInterval = 0;
        for track in sequencer.tracks {
            let trackEndPos = sequencer.secondsForBeats(track.offsetTime) + track.lengthInSeconds
            if length < trackEndPos {
                length = trackEndPos;
            }
        }
        return length;
    }
}
