//
//  AudioSession.swift
//  Orphee
//
//  Created by John Bob on 29/01/15.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import AVFoundation

/// This class is a wrapper around AVAudioSession.
class AudioSession {

    /// A short-hand to the AVAudioSession singleton.
    var session: AVAudioSession = AVAudioSession.sharedInstance();

    /// Defines the session as a **playback** session and the preferred sample rate to *graph's* default value.
    /// Then marks the session as active and updates *graph's* sample rate.
    ///
    /// - parameter graph:   The `AudioGraph` instance to use for this session.
    ///
    /// - returns: - `false` if one of the underlying routines fail.
    ///           - `true` if all goes well.
    func setupSession(inout graph: AudioGraph) -> Bool {

        do {
            try session.setCategory(AVAudioSessionCategoryPlayback);
        }
        catch (let err) {
            print("ERROR: \(err)");
            return false;
        }
        do {
            try session.setPreferredSampleRate(graph.sampleRate);
        }
        catch (let err) {
            print("ERROR: \(err)");
            return false;
        }
        do {
            try session.setActive(true)
        }
        catch (let err) {
            print("ERROR: \(err)");
            return false;
        }
        graph.sampleRate = session.sampleRate;
        return true;
    }
}
