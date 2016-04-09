//
// Created by John Bobington on 18/12/2015.
// Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import AVFoundation


public class AudioSequencerManager {
    private var sequencer: AVAudioSequencer

    private var timer: NSTimer?

    public var repeats: Bool = false

    public var isPlaying: Bool {
        return sequencer.playing
    }

    public init(engine: AVAudioEngine) {
        sequencer = AVAudioSequencer(audioEngine: engine)
    }

    deinit {
        sequencer.stop()
        for track in sequencer.tracks {
            track.destinationAudioUnit = nil
        }
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
        for (idx, track) in sequencer.tracks.enumerate() {
            track.destinationAudioUnit = units[idx]
        }
    }

    public func play() {
        self.sequencer.prepareToPlay()
        self.timer = NSTimer.every(0.05.seconds, act: timerCheck)
        do {
            try sequencer.start()
        }
        catch {
            self.timer?.invalidate()
            debugPrint(error)
        }
    }

    public func pause() {
        self.timer?.invalidate()
        self.sequencer.stop()
    }

    public func stop() {
        self.timer?.invalidate()
        self.sequencer.stop()
        self.sequencer.currentPositionInSeconds = 0
    }

    public func getSequenceDuration() -> NSTimeInterval {

        var length: NSTimeInterval = 0;
        for track in sequencer.tracks {
            let trackEndPos = track.offsetTime + track.lengthInBeats
            if length < trackEndPos {
                length = trackEndPos;
            }
        }
        return sequencer.secondsForBeats(length)
    }

    public func getCurrentPosition() -> NSTimeInterval {
        return sequencer.currentPositionInSeconds
    }

    public func setLoopFile(shouldLoop: Bool, loopCnt: Int = 0) {
        let loops: Int
        if loopCnt > 0 {
            loops = loopCnt
        } else {
            loops = AVMusicTrackLoopCount.Forever.rawValue
        }
        for track in sequencer.tracks {
            track.loopingEnabled = shouldLoop
            track.numberOfLoops = loops
        }
    }


    @objc private func timerCheck() {
        let duration = self.getSequenceDuration()
        let currentTime = self.getCurrentPosition()
        if currentTime >= duration {
            switch self.repeats {
            case true:
                self.sequencer.currentPositionInSeconds = 0
            case false:
                self.stop()
            }
        }
    }
}
