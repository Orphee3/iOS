//
//  eMidiEventType.swift
//  FileManagement
//
//  Created by Massil on 14/07/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit

///    Supported MIDI Events
///
///    - noteOn:        NoteOn event
///    - noteOff:       NoteOff event
///    - programChange: ProgramChange event
///    - timeSignature: TimeSignature event
///    - setTempo:      SetTempo event
///    - endOfTrack:    EndOfTrack event
///    - unknown:       Unsupported event
///
public enum eMidiEventType: UInt8 {

    // MIDI events
    case noteOn = 0x90
    case noteOff = 0x80
    case programChange = 0xC0

    // Meta events (preceded by 0xFF byte)
    case timeSignature = 0x58
    case setTempo = 0x51
    case endOfTrack = 0x2F

    // in case of some strange happening
    case unknown = 0x00

    /// An array containing all of this enum's values.
    static let allValues = [noteOn, noteOff, programChange, timeSignature, setTempo, endOfTrack, unknown];

    /// An array containing all supported non-meta MIDI events.
    static let MIDIEvents = [noteOn, noteOff, programChange];

    /// An array containing all supported meta MIDI events.
    static let METAEvents = [timeSignature, setTempo, endOfTrack];
}
