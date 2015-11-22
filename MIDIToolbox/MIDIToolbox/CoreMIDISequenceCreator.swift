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

/// Apple's default time resolution
let kTimeResolution_AppleDefault: UInt16 = 480;

/** CoreMIDISequenceCreator realizes pMIDIByteStreamBuilder

*/
public class CoreMIDISequenceCreator : pMIDIByteStreamBuilder {

    /// Provides the number of tracks.
    public var _trackCount: UInt16 {
        get {
            return self.trkCnt;
        }
    }

    /// Provides the time resolution.
    public let _timeResolution: UInt16;

    /// The container for MIDI events to be transformed to a Byte stream.
    var buffer: MusicSequence!;
    /// Internal count of tracks.
    var trkCnt: UInt16 = 0;

    ///  Initialises a new CoreMIDISequenceCreator.
    ///
    ///  - parameter trkNbr: The number of tracks. Leave default.
    ///  - parameter ppqn:   Pulse Per Quarter Note or time resolution.
    ///                   No way to change it: Leave Apple default time resolution.
    ///
    ///  - returns: An initialised CoreMIDISequenceCreator.
    public required init(trkNbr: UInt16 = 0, ppqn: UInt16 = kTimeResolution_AppleDefault) {

        _timeResolution = kTimeResolution_AppleDefault;
    }

    ///  Creates and sets up the MusicSequence buffer.
    public func buildMIDIBuffer() {

        buffer = CoreMIDISequenceCreator.makeMIDIBuffer();
    }

    ///  Adds the given track to the buffer
    ///
    ///  - parameter notes: The MIDI note events composing a track.
    ///  - parameter prog:  The MIDI program (instrument) associated with this track.
    public func addTrack(notes: [[MIDINoteMessage]], var prog: MIDIChannelMessage) {

        var trk: MusicTrack = MusicTrack();
        var ct: UInt32 = 0;

        MusicSequenceNewTrack(buffer, &trk);
        MusicSequenceGetTrackCount(buffer, &ct);

        MusicTrackNewMIDIChannelEvent(trk, 0, &prog);
        
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

    ///  Transforms the buffer to a Byte stream.
    ///
    ///  - returns: A Byte stream representation of a MIDI file.
    public func toData() -> NSData {

        var data: Unmanaged<CFData>? = Unmanaged<CFData>.passRetained(NSData());
        let st: OSStatus = MusicSequenceFileCreateData(buffer,  MusicSequenceFileTypeID.MIDIType, MusicSequenceFileFlags.EraseFile, Int16(_timeResolution), &data);
        if (st != noErr) {
            print("\(NSError(domain: NSOSStatusErrorDomain, code: Int(st), userInfo: nil))");
        }
        return data!.takeRetainedValue();
    }

    ///  Creates and initializes the MusicSequence object.
    ///
    ///  - returns: An initialized MusicSequence object.
    class func makeMIDIBuffer() -> MusicSequence {

        var s = MusicSequence();

        NewMusicSequence(&s);
        return s;
    }
}
