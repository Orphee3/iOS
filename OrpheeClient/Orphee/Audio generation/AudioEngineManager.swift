//
//  AudioEngineManager.swift
//  Orphee
//
//  Created by John Bobington on 18/12/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import AVFoundation
import AudioToolbox

public enum eSampleType {
    case Percussion
    case Melodic

    var bankMSB: UInt8 {
        switch self {
        case .Percussion:
            return UInt8(kAUSampler_DefaultPercussionBankMSB)
        case .Melodic:
            return UInt8(kAUSampler_DefaultMelodicBankMSB)
        }
    }

    var bankLSB: UInt8 {
        return UInt8(kAUSampler_DefaultBankLSB)
    }
}


public enum eAudioEngineManagerError: ErrorType {
    case SetInstrumentFailure(soundbank: String, program: UInt8, type: eSampleType, sampler: AVAudioUnitSampler)
}


public class AudioEngineManager {
    var engine: AVAudioEngine = AVAudioEngine()
    weak var out: AVAudioOutputNode!
    weak var mixer: AVAudioMixerNode!

    var samplers: [AVAudioUnitSampler] = []

    init() throws {
        out = engine.outputNode
        mixer = engine.mainMixerNode
        engine.connect(mixer, to: out, format: out.outputFormatForBus(0))
        try engine.start()
    }

    public func addSampler() -> AVAudioUnitSampler {
        let sampler = AVAudioUnitSampler()

        engine.attachNode(sampler)
        engine.connect(sampler, to: mixer, format: mixer.outputFormatForBus(0))

        samplers.append(sampler);
        return sampler
    }

    public func setInstrument(program: UInt8 = 1, soundBank bank: String, type: eSampleType, forSampler smplr: AVAudioUnitSampler) -> Bool {
        do {
            let bankURL: NSURL = NSURL(fileURLWithPath: bank)
            try smplr.loadSoundBankInstrumentAtURL(bankURL, program: program, bankMSB: type.bankMSB, bankLSB: type.bankLSB)
        } catch {
            debugPrint(error);
            return false
        }
        return true
    }

    public func setInstruments(programs: [UInt8], soundBank bank: String, type: eSampleType) throws {
        var it = 0
        for program in programs {
            let sampler = addSampler()
            guard setInstrument(program, soundBank: bank, type: type, forSampler: sampler) else {
                throw eAudioEngineManagerError.SetInstrumentFailure(soundbank: bank, program: program, type: type, sampler: sampler)
            }
            print("iteration #\(it)")
            ++it
        }
    }

    public func cleanEngine() {
        engine.stop()
        for sampler in samplers {
            engine.disconnectNodeInput(sampler)
            engine.disconnectNodeOutput(sampler)
            engine.detachNode(sampler)
            sampler.reset()
            sampler.AUAudioUnit.deallocateRenderResources()
        }
        engine.reset()
        samplers.removeAll()
    }

    deinit {
        print("cleaning")
        cleanEngine()
    }
}
