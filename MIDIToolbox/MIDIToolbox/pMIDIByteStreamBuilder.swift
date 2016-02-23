//
//  pMIDIByteStreamBuilder.swift
//  FileManagement
//
//  Created by JohnBob on 14/07/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import AudioToolbox

/// Midi file's header mark
let kMIDIFile_fileHeaderMark: String = "MThd";
/// Midi file header mark's size in Bytes.
let kMIDIFile_fileHeaderMarkSize: Int = 4;

/// Midi track's header mark
let kMIDIFile_trackMark: String = "MTrk";
/// Midi track header mark's size in Bytes.
let kMIDIFile_trackMarkSize: Int = 4;

/// Midi file's header length
let kMIDIFile_headerLength: Int = 6;
/// Midi track's header length
let kMIDITrack_headerLength: Int = 23;

/// Hexadecimal representation of a `time signature` event:
///   - 0xFF = MIDI Meta event
///   - 0x58 = MIDI time signature event
///   - 0x04 = 4 Bytes of data follow
let kMIDIEvent_timeSignature: [UInt8] = [0x00, 0xFF, 0x58, 0x04];

/// Hexadecimal representation of a `set tempo` event:
///   - 0xFF = MIDI Meta event
///   - 0x51 = MIDI set tempo event
///   - 0x03 = 3 Bytes of data follow
let kMIDIEvent_setTempo: [UInt8] = [0x00, 0xFF, 0x51, 0x03];

/// Hexadecimal representation of an `end of track` event:
///   - 0xFF = MIDI Meta event
///   - 0x2F = MIDI end of track event
///   - 0x00 = 0 Bytes of data follow
let kMIDIEvent_endOfTrack: [UInt8] = [0x00, 0xFF, 0x2F, 0x00];

/// Hexadecimal representation of the default `4/4` time signature:
/// 0x04 = time signature numerator is 4
/// 0x02 = time signature denominator is 2^2 = 4
/// 0x18 = metronome clicks once every 24 MIDI clock tick
/// 0x08 = number of 1/32nd notes per beat (8 = 1/4 note per beat).
let kMIDIEventDefaultData_timeSig: [UInt8] = [0x04, 0x02, 0x18, 0x08];

/// Hexadecimal representation of the default `120 bpm` tempo:
/// 0x07A120 = 500_000: 60_000_000/500_000 = 120 quarter_notes/minute
let kMIDIEventDefaultData_setTempo: [UInt8] = [0x07, 0xA1, 0x20];


/// pMIDIByteStreamBuilder protocol:
///
/// Any class building a MIDI byte stream/buffer needs to follow this protocol.
public protocol pMIDIByteStreamBuilder {

    /// The number of tracks to build
    var _trackCount: UInt16 { get };

    /// The time resolution, aka Pulse Per Quarter Note.
    var _timeResolution: UInt16 { get };

    // The file's time signature
    var _timeSignature: (UInt8, UInt8) { get }

    // The file's tempo
    var _tempo: UInt { get }

    ///    Default initializer.
    ///
    ///    - parameter  trkNbr: The number of tracks the file will contain.
    ///    - parameter    ppqn: The time resolution, aka Pulse Per Quarter Note.
    ///    - parameter timeSig: The file's time signature.
    ///    - parameter     bpm: The file's tempo
    ///
    ///    - returns: Initializes the MIDIByteStreamBuilder.
    init(trkNbr: UInt16, ppqn: UInt16, timeSig: (UInt8, UInt8), bpm: UInt);

	///  Setup the buffer.
    func buildMIDIBuffer();

    ///    Builds and adds a track to the MIDI file.
    ///
    ///    - parameter  notes:    The note events in the form of an array of arrays of MIDINoteMessages.
    ///                     Each array contains all the data for every note event sent at deltaTime = array index.
    ///    - parameter  prog:     The MIDI program (instrument) associated with this track.
    func addTrack(notes: [[MIDINoteMessage]], prog: MIDIChannelMessage);

    ///    Provides the formatted content as NSData.
    ///
    ///    - returns: NSData wrapper for the MIDI byte stream content.
    func toData() -> NSData;
}
