//
//  MIDIEventsProcessors.swift
//  FileManagement
//
//  Created by Massil on 10/04/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation

func isExpectedLength(length: UInt8, expected: UInt8) -> Bool {

    return length == expected;
}

/// MARK: META Events

func processTimeSigEvent(data: ByteBuffer) -> [UInt32] {

    let dataLength = data.getUInt8();

    if (isExpectedLength(dataLength, 4)) {

        var result: [UInt32] = [UInt32(data.getUInt8())];
        result.append(UInt32( pow(2, Double(data.getUInt8()))));
        result.append(UInt32(data.getUInt8()));
        result.append(UInt32(data.getUInt8()));

        return result;
    }
    debugPrintln("TimeSig got wrong length !");
    return [];
}

func processTempoEvent(data: ByteBuffer) -> [UInt32] {

    let dataLength = data.getUInt8();

    if (isExpectedLength(dataLength, 3)) {

        var bpm: UInt32 = 0;

        bpm = UInt32(data.getUInt8());
        bpm <<= 8;
        bpm |= UInt32(data.getUInt8());
        bpm <<= 8;
        bpm |= UInt32(data.getUInt8());
        return [60_000_000 / bpm];
    }
    debugPrintln("Tempo got wrong length !");
    return [];
}

func processEndOfTrack(data: ByteBuffer) -> [UInt32] {

    // No data to process actually...
    return [];
}


/// MARK: MIDI Events

func processProgramChange(data: ByteBuffer) -> [UInt32] {

    let channel = data.getUInt8() ^ 0xC0;
    let instruID = data.getUInt8();
    return [UInt32(channel), UInt32(instruID)];
}

func processNoteOnEvent(data: ByteBuffer) -> [UInt32] {

    let channel = data.getUInt8() ^ 0x90;
    let note = data.getUInt8();
    let velocity = data.getUInt8();
    return [UInt32(channel), UInt32(note), UInt32(velocity)];
}

func processNoteOffEvent(data: ByteBuffer) -> [UInt32] {

    let channel = data.getUInt8() ^ 0x80;
    let note = data.getUInt8();
    let velocity = data.getUInt8();
    return [UInt32(channel), UInt32(note), UInt32(velocity)];
}


/// MARK: Other

func processUnknownEvent(data: ByteBuffer) -> [UInt32] {

    var stop: Bool = false;
    var event: [UInt32] = [];

    while (!stop) {

        data.mark();

        let byte = data.getUInt8();
        let eventType = processStatusByte(byte);
        if (isMetaEventByte(byte) || eventType != MidiEventType.unknown || !data.hasRemaining) {

            stop = true;
            if (contains(MidiEventType.MIDIEvents, eventType)) {

                data.reset();
            }
        }
        else {
            event.append(UInt32(byte));
        }
    }
    return event;
}