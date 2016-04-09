//
//  AudioEngineManager.swift
//  Orphee
//
//  Created by John Bobington on 18/12/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import AVFoundation
import AudioToolbox
import Tools

import ObjectiveC.objc_sync

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

public enum eOperationResult {
    case NotStarted
    case Success(Any?)
    case Failure(Any?)
    case Interrupted(Any?)

    var resultValue: Any? {
        switch self {
        case .Success(let value):
            return value
        case .Failure(let value):
            return value
        case .Interrupted(let value):
            return value
        default:
            return nil
        }
    }
}

public protocol pOperationResult {
   var result: eOperationResult { get set }
}


private class EngineAction: NSOperation, pOperationResult {
    enum eType {
        case Start
        case Stop
    }

    weak var engine: AVAudioEngine!
    var result: eOperationResult
    let actionType: eType

    init(engine: AVAudioEngine, action: eType) {
        self.engine = engine
        self.actionType = action
        self.result = .NotStarted
    }

    override func main() {
        if self.cancelled {
            self.result = .Interrupted(nil)
            return
        }
        switch self.actionType {
        case .Start:
            do { try self.engine.start() }
            catch {
                self.result = .Failure(error)
                self.cancel()
                debugPrint(error)
            }
        case .Stop:
            self.engine.stop()
            self.result = .Success(nil)
        }
    }
}

private class SamplerSetup: NSOperation, pOperationResult {
    var result: eOperationResult

    weak var sampler: AVAudioUnitSampler!
    let program: UInt8
    let sf: NSURL
    let type: eSampleType

    init(smplr: AVAudioUnitSampler, soundbank: String, sampleType: eSampleType, instruID: UInt8) {
        self.sampler = smplr
        self.sf = NSURL(fileURLWithPath: soundbank)
        self.type = sampleType
        self.program = instruID

        print("setting up sampler with patch #\(program)")
        self.result = .NotStarted
    }

    override func main() {
        for _ in 0..<10 {
            if self.cancelled {
                self.result = .Interrupted(nil)
                return
            }
            if loadInstrument() { return }
        }
        self.cancel()
    }

    func loadInstrument() -> Bool {
        do {
            try self.sampler.loadSoundBankInstrumentAtURL(self.sf, program: self.program,
                                                          bankMSB: self.type.bankMSB, bankLSB: self.type.bankLSB)
        }
        catch {
            self.result = .Failure("Failed instrument setup: \(error)")
            return false
        }
        self.result = .Success(nil)
        return true
    }
}

public class AudioEngineManager {
    var engine: AVAudioEngine = AVAudioEngine()
    weak var out: AVAudioOutputNode!
    weak var mixer: AVAudioMixerNode!

    var samplers: [AVAudioUnitSampler] = []

    lazy var pendingSamplerOps: [NSOperation] = []
    lazy var pendingEngineOps: [NSOperation] = []
    lazy var samplerOpsQueue: NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "Sampler related operations' queue"
        queue.qualityOfService = .Background
        return queue
    }()

    lazy var engineOpsQueue: NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "Engine related operations' queue"
        queue.qualityOfService = .Background
//        queue.waitUntilAllOperationsAreFinished()
        return queue
    }()

    init() {
        self.out = engine.outputNode
        self.mixer = engine.mainMixerNode
        self.engine.connect(mixer, to: out, format: out.outputFormatForBus(0))
    }

    public func addSampler() -> AVAudioUnitSampler {
        let sampler = AVAudioUnitSampler()

        self.engine.attachNode(sampler)
        self.engine.connect(sampler, to: mixer, format: mixer.outputFormatForBus(0))

        self.samplers.append(sampler);
        return sampler
    }

    public func setInstruments(programs: [UInt8], soundBank bank: String, type: eSampleType) {
        let starter = EngineAction(engine: self.engine, action: .Start)
        let stopper = EngineAction(engine: self.engine, action: .Stop)
        for program in programs {
            let sampler = addSampler()
            let setup = SamplerSetup(smplr: sampler, soundbank: bank, sampleType: type, instruID: program)
            setup.completionBlock = {
                if setup.cancelled {
                    objc_sync_enter(starter)
                    switch starter.result {
                    case .NotStarted:
                        starter.result = .Interrupted(1)
                        starter.cancel()
                    case .Interrupted(let value):
                        if let errors = value as? Int {
                            starter.result = .Interrupted(errors + 1)
                        }
                    default: break
                    }
                    objc_sync_exit(starter)
                }
            }
            setup.addDependency(stopper)
            starter.addDependency(setup)
            self.pendingSamplerOps.append(setup)
        }
        starter.completionBlock = {
            switch (starter.cancelled, starter.result) {
            case (true, .Failure(_)):
                DefaultErrorAlert.makeAndPresent("Le lecteur a rencontré l'erreur suivante:", message: "Impossible de demarrer la lecture")
            case (true, .Interrupted(let value)):
                if let errors = value as? Int {
                    DefaultErrorAlert.makeAndPresent("Le lecteur a rencontré l'erreur suivante:", message: "Impossible de charger \(errors) des \(programs.count) instruments.")
                }
            default:
                break
            }
        }
        self.engineOpsQueue.addOperation(stopper)
        self.samplerOpsQueue.addOperations(self.pendingSamplerOps, waitUntilFinished: true)
        objc_sync_enter(starter)
        self.engineOpsQueue.addOperation(starter)
        objc_sync_exit(starter)
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
