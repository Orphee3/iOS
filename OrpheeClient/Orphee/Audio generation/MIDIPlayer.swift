//
// Created by John Bobington on 17/12/2015.
// Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import AVFoundation
import FileManagement

public enum eMIDIPlayerError: ErrorType {
    case InvalidFile(file: String)
}

public class MIDIPlayer: pMediaPlayer, pMediaPlayerTimeManager {

    public var duration: NSTimeInterval

    public var isPlaying: Bool {
        return playing;
    }

    public var currentTime: NSTimeInterval = 0

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
        do {
            self.data = data
            engine = try AudioEngineManager()
            sequence = AudioSequencerManager(engine: engine.engine)
        }
        catch {
            print("MIDIPlayer init Failed: \(error)")
            self.duration = 0
            return nil
        }
        guard sequence.loadFile(data) else {
            self.duration = 0
            return nil
        }
        self.duration = sequence.getSequenceDuration()
    }

    public func setupAudioGraph() -> Bool {
        let bank = NSBundle.mainBundle().pathForResource("SoundBanks/32MbGMStereo", ofType: "sf2")!
        let content = MIDIFileManager.parseData(data)
        let infos = content?[eOrpheeFileContent.TracksInfos.rawValue]
        if let _ = content,
           let infos   = infos as? [[String : Any]] {

            var patchs: [UInt8] = []
            for info in infos where info[eOrpheeFileContent.PatchID.rawValue] != nil {
                patchs.append(UInt8(info[eOrpheeFileContent.PatchID.rawValue]! as! Int))
            }
            try! engine.setInstruments(patchs, soundBank: bank, type: eSampleType.Melodic)
            sequence.setDestinationAudioUnit(engine.samplers)
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
        playing = false
    }

    func formatTime(time: NSTimeInterval) -> String {
        return "\(time)"
    }
}
