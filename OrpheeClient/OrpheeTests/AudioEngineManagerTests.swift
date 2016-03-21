//
//  AudioEngineManagerTests.swift
//  Orphee
//
//  Created by John Bobington on 18/12/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import XCTest

@testable import Orphee

class AudioEngineManagerTests: XCTestCase {
    let bundle = NSBundle(forClass: AudioEngineManagerTests.self)
    let soundbankPath = NSBundle.mainBundle().pathForResource("SoundBanks/32MbGMStereo", ofType: "sf2")!

    var engine: AudioEngineManager!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        engine = try! AudioEngineManager()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSetInstrument_fails__using_invalid_soundbankPath() {

        let sampler = AVAudioUnitSampler()
        XCTAssertFalse(engine.setInstrument(soundBank: "", type: .Melodic, forSampler: sampler))
    }

    func testSetInstrument_fails__using_incorrect_type() {

        let sampler = AVAudioUnitSampler()
        XCTAssertFalse(engine.setInstrument(soundBank: soundbankPath, type: .Percussion, forSampler: sampler))
    }

    func testSetInstrument_succeeds__using_correct_type__and_valid_soundbankPath() {

        let sampler = AVAudioUnitSampler()
        XCTAssertTrue(engine.setInstrument(soundBank: soundbankPath, type: .Melodic, forSampler: sampler))
    }

    func testAddSampler_return_isUsable() {
        let smp = engine.addSampler()

        XCTAssertTrue(engine.setInstrument(soundBank: soundbankPath, type: .Melodic, forSampler: smp))
    }

    func AudioGeneration() {
        let seq: AVAudioSequencer = AVAudioSequencer(audioEngine: engine.engine)

        XCTAssertDoesNotThrow(try seq.loadFromURL(NSURL(fileURLWithPath: bundle.pathForResource("xtreme", ofType: "mid")!), options: .SMF_PreserveTracks))

        var i: UInt8 = 80
        for track in seq.tracks {
            let smp = engine.addSampler()
            track.destinationAudioUnit = smp
            XCTAssertTrue(engine.setInstrument(i, soundBank: soundbankPath, type: eSampleType.Melodic, forSampler: smp))
            i += 4
        }

        seq.prepareToPlay()
        XCTAssertDoesNotThrow(try seq.start())
        usleep(20 * 1000 * 1000)
    }
}
