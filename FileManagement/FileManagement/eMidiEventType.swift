//
//  eMidiEventType.swift
//  FileManagement
//
//  Created by Massil on 14/07/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit


let kMIDIEventMaxSize_timeSignature: Int = 4;
let kMIDIEventMaxSize_programChange: Int = 2;
let kMIDIEventMaxSize_deltaTime: Int = 4;
let kMIDIEventMaxSize_noteEvent: Int = 3;
let kMIDIEventMaxSize_setTempo: Int = 3;
let kMIDIEventMaxSize_endOfTrack: Int = 1;
let kMIDIEventMaxSize_runningStatus: Int = -1;

///    Supported MIDI Events
///
///    - noteOn:        NoteOn event
///    - noteOff:       NoteOff event
///    - programChange: ProgramChange event
///    - timeSignature: TimeSignature event
///    - setTempo:      SetTempo event
///    - endOfTrack:    EndOfTrack event
///    - runningStatus: MIDI running status event
///    - unknown:       Unsupported event
public enum eMidiEventType: UInt8 {

    // MIDI events
    case noteOn = 0x90
    case noteOff = 0x80
    case programChange = 0xC0

    // Meta events (preceded by 0xFF byte)
    case timeSignature = 0x58
    case setTempo = 0x51
    case endOfTrack = 0x2F

    // running-status... Yay o/
    case runningStatus = 0x01; // no significance.

    // in case of some strange happening
    case unknown = 0xFE // no significance.

    /// An array containing all of this enum's values.
    static let allValues = [noteOn, noteOff, programChange, timeSignature, setTempo, endOfTrack, unknown];

    /// An array containing all supported non-meta MIDI events.
    static let MIDIEvents = [noteOn, noteOff, programChange];

    /// An array containing all supported meta MIDI events.
    static let METAEvents = [timeSignature, setTempo, endOfTrack];

    static let getMIDIEventFor = { (byte: UInt8) -> eMidiEventType? in

        let possibleEvents = eMidiEventType.MIDIEvents.filter({
            ($0.rawValue & byte == $0.rawValue)
                && ($0.rawValue ^ byte <= 0xF);
        });
        switch (possibleEvents.count) {
        case 0:
            return nil;
        case 1:
            return possibleEvents[0];
        default:
            debugPrint(kOrpheeDebug_eMidiEventType_tooManyPossibleEvents);
            return nil;
        }
    }

    static let sizeof = [
        eMidiEventType.noteOn : kMIDIEventMaxSize_noteEvent,
        eMidiEventType.noteOff : kMIDIEventMaxSize_noteEvent,
        eMidiEventType.programChange : kMIDIEventMaxSize_programChange,
        eMidiEventType.timeSignature : kMIDIEventMaxSize_timeSignature,
        eMidiEventType.setTempo : kMIDIEventMaxSize_setTempo,
        eMidiEventType.endOfTrack : kMIDIEventMaxSize_endOfTrack,
        eMidiEventType.runningStatus : kMIDIEventMaxSize_runningStatus,
        eMidiEventType.unknown : -1
    ];
}
