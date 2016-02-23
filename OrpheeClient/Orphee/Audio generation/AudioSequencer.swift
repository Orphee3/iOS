//
//  AudioSequencer.swift
//  SwiftSpecificities
//
//  Created by JohnBob on 05/08/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import AudioToolbox
import AVFoundation

public class cSeq {
    public let session: AVAudioSession = AVAudioSession.sharedInstance();
    public var sampler: AVAudioUnitSampler = AVAudioUnitSampler();
    public var engine: AVAudioEngine = AVAudioEngine();
    public lazy var sequencer: AVAudioSequencer = AVAudioSequencer(audioEngine: self.engine);

    func setupSession() {

        do {
            try session.setCategory(AVAudioSessionCategoryPlayback);
            try session.setActive(true);
        } catch {
            print("setupSession: \(error)");
        }
    }

    func setupSequencer() {

        sequencer = AVAudioSequencer(audioEngine: engine)
        do {
            try sequencer.loadFromURL(NSURL(fileURLWithPath: "/Users/Massil/Desktop/test 2.mid"), options: AVMusicSequenceLoadOptions.SMF_PreserveTracks);
        }
        catch {
            print("setupSequencer: \(error)");
        }
    }

    func setTracks(toDestination: AVAudioUnit) {

        print(sequencer.tracks);
        for track in sequencer.tracks {
            track.destinationAudioUnit = toDestination;
        }
    }

    public func setup() {
        setupSession();
        setupEngine();
        setupSequencer();
        setTracks(sampler);
        do {
            try engine.start();
        }
        catch {
            print("engineStart: \(error)");
        }
    }

    public func play() {
        do {
            sequencer.prepareToPlay();
            try sequencer.start();
        }
        catch {
            print("play: \(error)");
        }
    }

    func handleInterruption() {
        print("Pouet");
    }

    func setupEngine() {

        engine.connect(engine.mainMixerNode, to: engine.outputNode, format: engine.outputNode.outputFormatForBus(0));

        do {
            try sampler.loadSoundBankInstrumentAtURL(NSURL(fileURLWithPath: "/Users/Massil/Documents/FluidR3_GM.sf2"), program: 1, bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB), bankLSB: UInt8(kAUSampler_DefaultBankLSB));
        }
        catch {
            print("setupEngine: \(error)");
        }
        engine.attachNode(sampler);
        engine.connect(sampler, to: engine.mainMixerNode, format: engine.mainMixerNode.outputFormatForBus(0));
    }
    
    public func getMusicLength() -> NSTimeInterval {
        
        var length: NSTimeInterval = 0;
        for track in sequencer.tracks {
            let trackEndPos = sequencer.secondsForBeats(track.offsetTime) + track.lengthInSeconds;
            if length < trackEndPos {
                length = trackEndPos;
            }
        }
        return length;
    }
}