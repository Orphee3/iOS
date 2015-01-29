//
//  AudioSession.swift
//  Orphee
//
//  Created by John Bob on 29/01/15.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import AVFoundation

class AudioSession {

    var session: AVAudioSession = AVAudioSession.sharedInstance();

    func setupSession(inout graph: AudioGraph) -> Bool {

        var err: NSError? = NSError();

        if (!session.setCategory(AVAudioSessionCategoryPlayback, error: &err)) {
            println("ERROR: \(err?.localizedDescription)");
            return false;
        }

        if (!session.setPreferredSampleRate(graph.sampleRate, error: &err)) {
            println("ERROR: \(err?.localizedDescription)");
            return false;
        }
        if (!session.setActive(true, error: &err)) {
            println("ERROR: \(err?.localizedDescription)");
            return false;
        }
        graph.sampleRate = session.sampleRate;
        return true;
    }
}
