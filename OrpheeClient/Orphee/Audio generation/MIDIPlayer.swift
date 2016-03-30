//
// Created by John Bobington on 17/12/2015.
// Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import AVFoundation
import FileManagement

import Tools

public enum eMIDIPlayerError: ErrorType {
    case InvalidFile(file: String)
}

public class MIDIPlayer: pMediaPlayer, pMediaPlayerTimeManager {

    public var duration: NSTimeInterval

    public var isPlaying: Bool {
        return sequence.isPlaying;
    }

    public var currentTime: NSTimeInterval {
        get {
            return self.sequence.getCurrentPosition()
        }
        set {
            self.currentTime = self.sequence.getCurrentPosition()
        }
    }

    public var repeats: Bool = false {
        willSet {
            self.sequence.repeats = newValue
            self.sequence.setLoopFile(newValue)
        }
    }

    private var playing = false
    private let data: NSData

    var sequence: AudioSequencerManager! = nil
    var engine: AudioEngineManager! = nil

    public convenience init?(path: String) throws {
        guard let data = NSData(contentsOfFile: path) else {
            throw eMIDIPlayerError.InvalidFile(file: path)
        }
        self.init(data: data)
    }

    required public init?(data: NSData) {
        self.data = data
        engine = AudioEngineManager()
        sequence = AudioSequencerManager(engine: engine.engine)
        guard sequence.loadFile(data) else {
            self.duration = 0
            return nil
        }
        self.duration = sequence.getSequenceDuration()
    }

    public func setupAudioGraph() -> Bool {
        let bank    = NSBundle.mainBundle().pathForResource("SoundBanks/32MbGMStereo", ofType: "sf2")!
//        let bank    = NSBundle.mainBundle().pathForResource("xtreme", ofType: "mid")! // test
        let content = MIDIFileManager.parseData(data)
        let infos   = content?[eOrpheeFileContent.TracksInfos.rawValue]
        if let infos = infos as? [[String : Any]?] where infos.count > 0 {

            let patchs = infos
                .flatMap { $0 }
                .filter { $0[eOrpheeFileContent.PatchID.rawValue] != nil }
                .map { UInt8($0[eOrpheeFileContent.PatchID.rawValue]! as! Int) }
            self.engine.setInstruments(patchs, soundBank: bank, type: eSampleType.Melodic)
            self.sequence.setDestinationAudioUnit(self.engine.samplers)
            return true
        }
        else {
            debugPrint(infos)
        }
        return false
    }

    func play() {
        sequence.play()
    }

    func pause() {
        sequence.pause()
    }

    func stop() {
        sequence.stop()
    }

    func repeatCnt(loops: Int? = 0) {
        switch loops {
            case nil:
                sequence.setLoopFile(false)
        case .Some(let cnt) where cnt > 0:
            sequence.setLoopFile(true)
        default:
            sequence.setLoopFile(true)
        }
    }

    class func formatTime(time: NSTimeInterval) -> String {
        let minutes = Int(floor(round(time) / 60));
        let seconds = Int(round(time)) - (minutes * 60);
        let formatedString = String(format: "%d:%02d", minutes, seconds)
        return formatedString
    }
}
