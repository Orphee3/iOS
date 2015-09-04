//
//  CoreMIDISequenceCreator.swift
//  FileManagement
//
//  Created by Massil on 14/07/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit
import Foundation
import AudioToolbox

let kTimeResolution_AppleDefault: UInt16 = 480;

/** CoreMIDISequenceCreator realizes pMIDIByteStreamBuilder

*/
public class CoreMIDISequenceCreator : pMIDIByteStreamBuilder {

    public var _trackCount: UInt16 {
        get {
            return self.trkCnt;
        }
    }

    public let _timeResolution: UInt16;

    var buffer: MusicSequence!;
    var trkCnt: UInt16 = 0;

    ///    Initialises a new CoreMIDISequenceCreator.
    ///
    ///    :param: trkNbr The number of tracks. Leave default.
    ///    :param: ppqn   Pulse Per Quarter Note or time resolution.
    ///                   No way to change it: Leave Apple default time resolution.
    ///
    ///    :returns: An initialised CoreMIDISequenceCreator.
    public required init(trkNbr: UInt16 = 0, ppqn: UInt16 = kTimeResolution_AppleDefault) {

        _timeResolution = kTimeResolution_AppleDefault;
    }

    public func buildMIDIBuffer() {

        buffer = CoreMIDISequenceCreator.makeMIDIBuffer();
    }

    public func addTrack(notes: [[MIDINoteMessage]]) {

        var trk: MusicTrack = MusicTrack();
        var ct: UInt32 = 0;

        MusicSequenceNewTrack(buffer, &trk);
        MusicSequenceGetTrackCount(buffer, &ct);

        var endNote = MIDINoteMessage(channel: UInt8(trkCnt), note: 0, velocity: 0, releaseVelocity: 0, duration: eNoteLength.crotchet.rawValue);
        var tmStmp: Float64 = 0;
        for (idx, dtNotes) in notes.enumerate() {
            let curTmStmp = tmStmp;
            if (dtNotes.count == 0) {
                tmStmp += Float64(eNoteLength.crotchet.rawValue);
            }
            for note in dtNotes {
                var curNote = note;
                if (curTmStmp == tmStmp && idx != 0) {
                    tmStmp += Float64(note.duration);
                }
                MusicTrackNewMIDINoteEvent(trk, tmStmp, &curNote);
            }
        }
        MusicTrackNewMIDINoteEvent(trk, tmStmp, &endNote);
        trkCnt++;
    }

    public func toData() -> NSData {

        var data: Unmanaged<CFData>? = Unmanaged<CFData>.passRetained(NSData());
        let st: OSStatus = MusicSequenceFileCreateData(buffer,  MusicSequenceFileTypeID.MIDIType, MusicSequenceFileFlags.EraseFile, Int16(_timeResolution), &data);
        if (st == noErr) {
            print("\(NSError(domain: NSOSStatusErrorDomain, code: Int(st), userInfo: nil))");
        }
        return data!.takeRetainedValue();
    }

    class func makeMIDIBuffer() -> MusicSequence {

        var s = MusicSequence();

        NewMusicSequence(&s);
        return s;
    }
}
