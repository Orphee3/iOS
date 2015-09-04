//
//  eMidiEventType.swift
//  FileManagement
//
//  Created by Massil on 14/07/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit

let kMIDIEventMaxSize_noteEvent: Int     = 3;
let kMIDIEventMaxSize_programChange: Int = 2;

let kMIDIEventMaxSize_timeSignature: Int = 4;
let kMIDIEventMaxSize_setTempo: Int      = 3;
let kMIDIEventMaxSize_endOfTrack: Int    = 1;

let kMIDIEventMaxSize_deltaTime: Int     = 4;
let kMIDIEventMaxSize_runningStatus: Int = -1;

///    - **Range of midi event types:**
///
///      - Meta events:           `0xFF` followed by *type byte* ranging from `0x00` to `0x7F`.
///      - MIDI events:           *Type byte* ranges from `0x8X` to `0xEX` where `X` represents the channel (0x00 to 0x0F).
///      - SysEx events:          *Type byte* is either `0xF0` or `0xF7`.
///      - SysCommon events:      *Type byte* ranges from `0xF1` to `0xF6`. Should not be present in Midi files.
///      - SysRealTime events:    *Type byte* ranges from `0xF8` to `0xFE`. Should not be present in Midi files.
///
///    - Supported MIDI events:
///
///      - `noteOn`:                *Note on* event
///      - `noteOff`:               *Note off* event
///      - `programChange`:         *Program change* event
///
///    - Supported Meta events:
///
///      - `timeSignature`:         *Time signature* event
///      - `setTempo`:              *Tempo change* event
///      - `endOfTrack`:            *End of track* event
///
///    - Convenience events for parsing: No-collision guaranteed
///
///      - `runningStatus`:         MIDI running status -- Not an event.
///      - `unknown`:               Unsupported event
///
///    - Unsupported MIDI events:
///
///      - `aftertouch`:            *Key aftertouch* event
///      - `ctrlChange`:            *Controller change* event
///      - `chanPressure`:          *Channel pressure* event
///      - `pitchChange`:           *Pitch change* event
///
///    - Unsupported Meta events:
///
///      - `sequenceNbr`:           *Sequence number* event
///      - `text`:                  *Text* event
///      - `copyright`:             *Copyright* event
///      - `trkName`:               *Track name* event
///      - `instruName`:            *Instrument name* event
///      - `lyrics`:                *Lyrics* event
///      - `marker`:                *Marker* event
///      - `cuePoint`:              *Cue point* event
///      - `chanPrefix`:            *Channel prefix* event
///      - `smpteOffset`:           *SMPTE offset* event
///      - `keySignature`:          *Key signature* event
///      - `seqSpecific`:           *Sequencer specific data* event
///
///    - Unsupported SysEx events:
///
///      - `sysExSingle`:           *Complete system exclusive data* event
///      - `sysExPacket`:           *System exclusive data as packets* event
///
public enum eMidiEventType: UInt8 {

    ///    Exceptions related to eMidiEventType
    ///
    ///    - tooManyEventsForByte: Multiple events for given byte.
    ///    - invalidMetaEvent:     The given byte is declared as a Meta event but isn't valid.
    public enum eMidiEventTypeErrors: ErrorType {
        ///    Multiple events for given byte.
        case tooManyEventsForByte(byte: UInt8, String);

        ///    The given byte is declared as a Meta event but isn't valid.
        case invalidMetaEvent(byte: UInt8, String);

        /// The given byte is declared as a Midi event but isn't valid.
        case invalidMidiEvent(byte: UInt8, String);

        /// The given byte cannot be construed as the given eventType.
        case byteIsNotOfGivenType(byte: UInt8, type: eMidiEventType, String);
    }

    /*
    ////////////////////////
    ///// MIDI events //////
    ////////////////////////
    */
    /////// supported ///////
    case noteOn        = 0x90
    case noteOff       = 0x80
    case programChange = 0xC0

    ////// unsupported //////
    case afterTouch    = 0xA0
    case ctrlChange    = 0xB0
    case chanPressure  = 0xD0
    case pitchChange   = 0xE0

    /////////////////////////
    ////// Meta events //////
    /////////////////////////
    /////// supported ///////
    case timeSignature = 0x58
    case setTempo      = 0x51
    case endOfTrack    = 0x2F

    ////// unsupported //////
    case sequenceNbr   = 0x00
    case text          = 0x01
    case copyright     = 0x02
    case trkName       = 0x03
    case instruName    = 0x04
    case lyrics        = 0x05
    case marker        = 0x06
    case cuePoint      = 0x07
    case chanPrefix    = 0x20
    case smpteOffset   = 0x54
    case keySignature  = 0x59
    case seqSpecific   = 0x7F

    /////////////////////////
    ////// SysEx events /////
    /////////////////////////
    ////// unsupported //////
    case sysExSingle   = 0xF0
    case sysExPacket   = 0xF7

    /////////////////////////
    //////// Custom /////////
    /////////////////////////
    /////// supported ///////
    case runningStatus = 0xF4 // Arbitrary.
    case unknown       = 0xF5 // Arbitrary.

    /// An array containing all of this enum's values.
    static let allValues = [
        noteOn, noteOff, programChange,
        afterTouch, ctrlChange, chanPressure, pitchChange,
        timeSignature, setTempo, endOfTrack,
        sequenceNbr, text, copyright, trkName, instruName, lyrics, marker, cuePoint, chanPrefix, smpteOffset, keySignature, seqSpecific,
        sysExSingle, sysExPacket,
        runningStatus, unknown,
    ];

    /// An array containing all of this enum's Midi, Meta and SysEx events.
    static let allEvents = allMIDIEvents + allMETAEvents + [sysExSingle, sysExPacket];

    /// An array containing supported MIDI events.
    static let MIDIEvents = [noteOn, noteOff, programChange];
    /// An array containing all MIDI events.
    static let allMIDIEvents = MIDIEvents + [
        afterTouch, ctrlChange, chanPressure, pitchChange
    ];

    /// An array containing supported Meta events.
    static let METAEvents = [timeSignature, setTempo, endOfTrack];
    /// An array containing all Meta events.
    static let allMETAEvents = METAEvents + [
        sequenceNbr, text, copyright, trkName, instruName, lyrics, marker, cuePoint, chanPrefix, smpteOffset, keySignature, seqSpecific,
    ];

    static let unsupported = [
        sysExSingle, sysExPacket,
        sequenceNbr, text, copyright, trkName, instruName, lyrics, marker, cuePoint, chanPrefix, smpteOffset, keySignature, seqSpecific,
        afterTouch, ctrlChange, chanPressure, pitchChange
    ];

    static let sizeof = [
        eMidiEventType.noteOn : kMIDIEventMaxSize_noteEvent,
        eMidiEventType.noteOff : kMIDIEventMaxSize_noteEvent,
        eMidiEventType.programChange : kMIDIEventMaxSize_programChange,
        eMidiEventType.timeSignature : kMIDIEventMaxSize_timeSignature,
        eMidiEventType.setTempo : kMIDIEventMaxSize_setTempo,
        eMidiEventType.endOfTrack : kMIDIEventMaxSize_endOfTrack,
        eMidiEventType.runningStatus : kMIDIEventMaxSize_runningStatus,
        eMidiEventType.unknown : 1
    ];

    static func getMidiEventTypeFor(byte: UInt8, isMeta meta: Bool = false) throws -> eMidiEventType {

        do {
            let event = try _getUnsafeEventTypeFor(byte, isMeta: meta);
            switch (event, isHighestOrderBitSet(byte), meta) {
            case (.Some(let eventType), _, _):
                guard !eMidiEventType.unsupported.contains(eventType) else {
                    return .unknown;
                }
                return eventType;
            case (_, false, false):
                return .runningStatus;
            default:
                return .unknown;
            }
        }
        catch {
            throw error
        }
    }

    private static func _getUnsafeEventTypeFor(byte: UInt8, isMeta meta: Bool = false) throws -> eMidiEventType? {
        var possibleEvents: [eMidiEventType] = []
        switch(meta, 0x7F < byte, byte < 0xF0) {
        case (true, true, _):
            throw eMidiEventTypeErrors.invalidMetaEvent(byte: byte, "Invalid Meta event type: \(byte) > \(0x7f)");
        case (true, false, _):
            if let event = eMidiEventType(rawValue: byte) {
                possibleEvents = [event];
            }
        case (false, true, true):
            possibleEvents = eMidiEventType.allMIDIEvents.filter() {
                ($0.rawValue & byte == $0.rawValue) && ($0.rawValue ^ byte <= 0x0F);
            }
        default:
            break;
        }
        if possibleEvents.count > 1 {
            throw eMidiEventTypeErrors.tooManyEventsForByte(byte: byte, "Too many events for byte: \(byte)\nEvents: \(possibleEvents)");
        }
        return possibleEvents.first;
    }

    public static func isByte(byte: UInt8, aMidiEventOfType type: eMidiEventType) throws -> Bool {
        guard allMIDIEvents.contains(type) else {
            throw eMidiEventTypeErrors.invalidMidiEvent(byte: byte, "Invalid Midi event type: \(byte)");
        }
        return (type.rawValue & byte == type.rawValue) && ((type.rawValue ^ byte) < 0x10)
    }
}
