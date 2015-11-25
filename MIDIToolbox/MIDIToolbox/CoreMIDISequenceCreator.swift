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
public final class CoreMIDISequenceCreator : pMIDIByteStreamBuilder {

    /// Provides the number of tracks.
    public var _trackCount: UInt16 {
        get {
            return self.trkCnt;
        }
    }

    /// Provides the time resolution.
    public let _timeResolution: UInt16;
    // The file's time signature
    public let _timeSignature: (UInt8, UInt8);
    // The file's tempo
    public let _tempo: UInt;

    /// The container for MIDI events to be transformed to a Byte stream.
    var buffer: MusicSequence!;
    /// Internal count of tracks.
    var trkCnt: UInt16 = 0;

    ///    Default initializer.
    ///
    ///    - parameter  trkNbr: Unused parameter.
    ///    - parameter    ppqn: The time resolution, aka Pulse Per Quarter Note.
    ///    - parameter timeSig: The file's time signature.
    ///    - parameter     bpm: The file's tempo
    ///
    ///    - returns: Initializes the MIDIByteStreamBuilder.
    public init(trkNbr: UInt16 = 0, ppqn: UInt16 = kTimeResolution_AppleDefault, timeSig: (UInt8, UInt8), bpm: UInt) {

        _timeResolution   = kTimeResolution_AppleDefault
        _timeSignature    = (timeSig.0, UInt8(log10(Double(timeSig.1)) / log10(2)))
        _tempo            = bpm
    }

    ///  Creates and sets up the MusicSequence buffer.
    public func buildMIDIBuffer() {

        buffer = CoreMIDISequenceCreator.makeMIDIBuffer();
        setupTempoTrack()
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
                curNote.channel = UInt8(trkCnt);
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
        let st: OSStatus = MusicSequenceFileCreateData(buffer, MusicSequenceFileTypeID.MIDIType, MusicSequenceFileFlags.EraseFile, Int16(_timeResolution), &data);
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

    func setupTempoTrack() {
        var trk = MusicTrack()
        var timeSigEvent = MIDIMetaEvent.buildMetaEvent(eMidiEventType.timeSignature.rawValue, data: [_timeSignature.0, _timeSignature.1, 0x18, 0x08])
        var tempoEvent = MIDIMetaEvent.buildMetaEvent(eMidiEventType.setTempo.rawValue, data: decomposeToBytes(60_000_000 / _tempo))
        print(MusicSequenceGetTempoTrack(buffer, &trk))
        print(MusicTrackNewMetaEvent(trk, 0, timeSigEvent))
        print(MusicTrackNewMetaEvent(trk, 0, tempoEvent))
        MIDIMetaEvent.clean(timeSigEvent)
        MIDIMetaEvent.clean(tempoEvent)
    }
}

extension MIDIMetaEvent {

    static func buildMetaEvent(type: UInt8, data: [UInt8]) -> UnsafeMutablePointer<MIDIMetaEvent> {
        let size = sizeof(MIDIMetaEvent) + data.count
        let memoryPtr = UnsafeMutablePointer<UInt8>.alloc(size)
        let metaEvtPtr: UnsafeMutablePointer<MIDIMetaEvent> = UnsafeMutablePointer(memoryPtr)

        metaEvtPtr.memory.metaEventType = type
        metaEvtPtr.memory.dataLength = UInt32(data.count)
        memcpy(memoryPtr + 8, data, data.count)

        return metaEvtPtr
    }

    static func clean(event: UnsafeMutablePointer<MIDIMetaEvent>) {
        let size = sizeof(MIDIMetaEvent) + Int(event.memory.dataLength)
        event.dealloc(size)
    }
}