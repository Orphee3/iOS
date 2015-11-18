//
//  eMidiEventType.swift
//  FileManagement
//
//  Created by Massil on 14/07/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit

/// The maximum size of a noteOn or noteOff event.
let kMIDIEventMaxSize_noteEvent: Int     = 3;
/// The maximum size of a programChange event.
let kMIDIEventMaxSize_programChange: Int = 2;

/// The maximum size of a timeSignature event.
let kMIDIEventMaxSize_timeSignature: Int = 4;
/// The maximum size of a setTempo event.
let kMIDIEventMaxSize_setTempo: Int      = 3;
/// The maximum size of a EndOfTrack event.
let kMIDIEventMaxSize_endOfTrack: Int    = 1;

/// The maximum size of deltaTimes.
let kMIDIEventMaxSize_deltaTime: Int     = 4;
/// Running status events omits the status byte.
let kMIDIEventMaxSize_runningStatus: Int = -1;


extension eMidiEventType :Equatable {}

///  ## Range of midi event types ##
///
///    - Meta events:           `0xFF` followed by *status byte* ranging from `0x00` to `0x7F` included.
///    - MIDI events:           *status byte* ranges from `0x8X` to `0xEX` where `X` represents the channel (0x00 to 0x0F).
///    - SysEx events:          *status byte* is either `0xF0` or `0xF7`.
///    - SysCommon events:      *status byte* ranges from `0xF1` to `0xF6`. Should not be present in Midi files.
///    - SysRealTime events:    *status byte* ranges from `0xF8` to `0xFE`. Should not be present in Midi files.
///
///  ### MIDI Events ###
///    - Supported:
///
///      - `noteOn`
///      - `noteOff`
///      - `programChange`
///
///    - Unsupported:
///
///      - `aftertouch`
///      - `ctrlChange`
///      - `chanPressure`
///      - `pitchChange`
///
///  ### Meta Events ###
///    - Supported:
///
///      - `timeSignature`
///      - `setTempo`
///      - `endOfTrack`
///
///    - Unsupported:
///
///      - `sequenceNbr`
///      - `text`
///      - `copyright`
///      - `trkName`
///      - `instruName`
///      - `lyrics`
///      - `marker`
///      - `cuePoint`
///      - `chanPrefix`
///      - `smpteOffset`
///      - `keySignature`
///      - `seqSpecific`
///
///  ### System exclusive events ###
///    - Unsupported:
///
///      - `sysExSingle`
///      - `escapeSequence`
///
///  ### Convenience Events ###
///    - for parsing
///
///      - `runningStatus`
///      - `unknown`
///
public enum eMidiEventType: UInt8 {

    ///    Exceptions related to eMidiEventType
    ///
    ///    - tooManyEventsForByte: Multiple events for given byte.
    ///    - invalidMetaEvent:     The given byte is declared as a Meta event but isn't valid.
    public enum eMidiEventTypeError: ErrorType {
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
    /////// supported //////
    */
    ///  Note on event
    case noteOn         = 0x90
    ///  Note off event
    case noteOff        = 0x80
    ///  ProgramChange event
    case programChange  = 0xC0

    // //// unsupported /////
    /// Key aftertouch event
    case afterTouch     = 0xA0
    /// Controller change event
    case ctrlChange     = 0xB0
    ///  Channel pressure event
    case chanPressure   = 0xD0
    ///  Pitch change event
    case pitchChange    = 0xE0

    /*
    ////////////////////////
    ////// Meta events //////
    /////////////////////////
    */
    // ///// supported ///////
    /// Time signature event
    case timeSignature  = 0x58
    /// Tempo change event
    case setTempo       = 0x51
    /// End of track event
    case endOfTrack     = 0x2F

    // //// unsupported //////
    /// Sequence number event
    case sequenceNbr    = 0x00
    /// Text event
    case text           = 0x01
    /// Copyright event
    case copyright      = 0x02
    /// Track name event
    case trkName        = 0x03
    /// Instrument name event
    case instruName     = 0x04
    /// Lyrics event
    case lyrics         = 0x05
    /// Marker event
    case marker         = 0x06
    /// Cue point event
    case cuePoint       = 0x07
    /// Channel prefix event
    case chanPrefix     = 0x20
    /// SMPTE offset event
    case smpteOffset    = 0x54
    /// Key signature event
    case keySignature   = 0x59
    /// Sequencer specific data event
    case seqSpecific    = 0x7F

    /*
    ////////////////////////
    ////// SysEx events /////
    /////////////////////////
    */
    // //// unsupported //////
    /// Complete system exclusive data event
    case sysExSingle    = 0xF0
    /// Escape sequence event
    case escapeSequence = 0xF7

    /*
    ////////////////////////
    //////// Custom /////////
    /////////////////////////
    */
    /// MIDI running status
    /// - attention: This is not an actual event with an arbitrary associated value.
    case runningStatus = 0xF4
    /// Unknown event.
    /// - attention: This is not an actual event with an arbitrary associated value.
    case unknown       = 0xF5
    /// Unsupported event.
    /// - attention: This is not an actual event with an arbitrary associated value.
    case unsupported   = 0xF6
    
    /// An array containing all of this enum's values.
    static let kAllValues: Set<eMidiEventType> = [
        noteOn, noteOff, programChange,
        afterTouch, ctrlChange, chanPressure, pitchChange,
        timeSignature, setTempo, endOfTrack,
        sequenceNbr, text, copyright, trkName, instruName, lyrics, marker, cuePoint, chanPrefix, smpteOffset, keySignature, seqSpecific,
        sysExSingle, escapeSequence,
        runningStatus, unknown,
    ];

    /// An array containing all of this enum's Midi, Meta and SysEx events.
    static let kAllEvents: Set<eMidiEventType> = kAllMIDIEvents.union(kAllMETAEvents).union([sysExSingle, escapeSequence]);

    /// An array containing supported MIDI events.
    static let kMIDIEvents: Set<eMidiEventType> = [noteOn, noteOff, programChange];
    /// An array containing all MIDI events.
    static let kAllMIDIEvents: Set<eMidiEventType> = kMIDIEvents.union([
        afterTouch, ctrlChange, chanPressure, pitchChange
    ]);

    /// An array containing supported Meta events.
    static let kMETAEvents: Set<eMidiEventType> = [timeSignature, setTempo, endOfTrack];
    /// An array containing all Meta events.
    static let kAllMETAEvents: Set<eMidiEventType> = kMETAEvents.union([
        sequenceNbr, text, copyright, trkName, instruName, lyrics, marker, cuePoint, chanPrefix, smpteOffset, keySignature, seqSpecific,
    ]);

    /// An array containing all unsupported events.
    static let kUnsupported: Set<eMidiEventType> = [
        sysExSingle, escapeSequence,
        sequenceNbr, text, copyright, trkName, instruName, lyrics, marker, cuePoint, chanPrefix, smpteOffset, keySignature, seqSpecific,
        afterTouch, ctrlChange, chanPressure, pitchChange
    ];

    /// A dictionnary mapping each supported event to it's maximum size (in Bytes).
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

    ///  Determines the event type of a given byte.
    ///
    ///  - parameter byte: A byte representing an event.
    ///  - parameter meta: A boolean indicating if `byte` is supposed to be a meta event.
    ///
    ///  - throws: An eMidiEventTypeError value.
    ///
    ///  - returns: The event type of `byte`.
    static func getMidiEventTypeFor(byte: UInt8, isMeta meta: Bool = false) throws -> eMidiEventType {

        do {
            let event = try _getUnsafeEventTypeFor(byte, isMeta: meta);
            switch (event, isHighestOrderBitSet(byte), meta) {
            case (.Some(let eventType), _, _):
                guard !eMidiEventType.kUnsupported.contains(eventType) else {
                    return .unsupported;
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
            throw eMidiEventTypeError.invalidMetaEvent(byte: byte, "Invalid Meta event type: \(byte) > \(0x7f)");
        case (true, false, _):
            if let event = eMidiEventType(rawValue: byte) {
                possibleEvents = [event];
            }
        case (false, true, true):
            possibleEvents = eMidiEventType.kAllMIDIEvents.filter() {
                ($0.rawValue & byte == $0.rawValue) && ($0.rawValue ^ byte <= 0x0F);
            }
        default:
            break;
        }
        if possibleEvents.count > 1 {
            throw eMidiEventTypeError.tooManyEventsForByte(byte: byte, "Too many events for byte: \(byte)\nEvents: \(possibleEvents)");
        }
        return possibleEvents.first;
    }

    ///  Checks if a given byte represents a MIDI event of the given type
    ///
    ///  - parameter byte: A byte representing a MIDI event.
    ///  - parameter type: The expected type of MIDI event.
    ///
    ///  - throws: eMidiEventTypeError.invalidMidiEvent if expected type is not a MIDI event.
    ///
    ///  - returns: `true` if the given byte represents the expected MIDI event type, `false` otherwise.
    public static func isByte(byte: UInt8, aMidiEventOfType type: eMidiEventType) throws -> Bool {
        guard kAllMIDIEvents.contains(type) else {
            throw eMidiEventTypeError.invalidMidiEvent(byte: byte, "Invalid Midi event type: \(byte)");
        }
        return (type.rawValue & byte == type.rawValue) && ((type.rawValue ^ byte) < 0x10)
    }
}
