//
//  MidiEvent.swift
//  FileManagement
//
//  Created by JohnBob on 10/04/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation


/** MidiEventType enumeration

*/


enum MidiEventType: UInt8 {

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

    static let allValues = [noteOn, noteOff, programChange, timeSignature, setTempo, endOfTrack, unknown];
    static let MIDIEvents = [noteOn, noteOff, programChange];
    static let METAEvents = [timeSignature, setTempo, endOfTrack];
}


/** MidiEvent protocol

*/


protocol MidiEvent {

    typealias dataSource;

    var type: MidiEventType { get };
    var data: [UInt32]? { get set };

    func readData(rawData: dataSource);
}


/** TimedMidiEvent protocol

*/


protocol TimedMidiEvent: MidiEvent {

    var deltaTime: UInt32 { get };

    init(type: MidiEventType, deltaTime: UInt32, reader: (rawData:dataSource) -> [UInt32]);
}
