//
//  MIDIEventsProcessorsHelpers.swift
//  FileManagement
//
//  Created by JohnBob on 14/07/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation


public func isExpectedLength(length: UInt8, expected: UInt8) -> Bool {

    return length == expected;
}

public func makeMidiEvent(delta: UInt32 = 0, eventType: eMidiEventType, buffer: ByteBuffer) -> GenericMidiEvent<ByteBuffer> {

    var event: GenericMidiEvent<ByteBuffer>? = nil;
    switch eventType {
    case .noteOn:
        event = TimedEvent(type: eventType, deltaTime: delta, reader: processNoteOnEvent);
    case .noteOff:
        event = TimedEvent(type: eventType, deltaTime: delta, reader: processNoteOffEvent);
    case .programChange:
        event = TimedEvent(type: eventType, deltaTime: delta, reader: processProgramChange);
    case .timeSignature:
        event = GenericMidiEvent(type: eventType, reader: processTimeSigEvent);
    case .setTempo:
        event = GenericMidiEvent(type: eventType, reader: processTempoEvent);
    case .endOfTrack:
        event = GenericMidiEvent(type: eventType, reader: processEndOfTrack);
    default:
        event = GenericMidiEvent(type: eventType, reader: processUnknownEvent);
    }
    event!.readData(buffer);
    return event!;
}

public func getNextEvent(buffer: ByteBuffer, inout isMetaEvent: Bool) -> UInt8 {

    if (!isMetaEvent) {
        buffer.mark();
    }

    let byte = buffer.getUInt8()

    if (byte == 0xFF || byte == 0) {

        isMetaEvent = isMetaEventByte(byte)
        return getNextEvent(buffer, isMetaEvent: &isMetaEvent);
    }
    if (!isMetaEvent) {
        buffer.reset();
    }
    return byte;
}

public func isMetaEventByte(currentByte: UInt8) -> Bool {

    return currentByte == 0xFF
}

public func processStatusByte(statusByte: UInt8) -> eMidiEventType {

    if let eventType = eMidiEventType(rawValue: statusByte) {
        return eventType;
    }
    for eventType in eMidiEventType.MIDIEvents {

        if ((eventType.rawValue & statusByte == eventType.rawValue)
            && (eventType.rawValue ^ statusByte < 0xF)) {

                return eventType;
        }
    }
    return eMidiEventType.unknown;
}
