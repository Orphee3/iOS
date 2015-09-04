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

public func buildMIDIEventProcessor(event: eMidiEventType, chan: UInt8?) -> (data: ByteBuffer) -> [UInt32] {

    switch event {
        case .noteOn, .noteOff, .programChange:
            return { (data: ByteBuffer) -> [UInt32] in

                var values: [UInt8] = chan == nil ? [data.getUInt8() ^ event.rawValue] : [chan!];
                values += data.getUInt8(eMidiEventType.sizeof[event]! - 1);
                return values.map( { UInt32($0); } );
            }
        case .unknown:
            return processUnknownEvent;
        case .setTempo:
            return processTempoEvent;
        case .timeSignature:
            return processTimeSigEvent;
        default:
            return processEndOfTrack;
    }
}

public func makeMidiEvent(eventType: eMidiEventType, delta: UInt32 = 0, chan: UInt8? = nil) -> GenericMidiEvent<ByteBuffer> {

    let event: GenericMidiEvent<ByteBuffer>!;
    let processor = buildMIDIEventProcessor(eventType, chan: chan);

    if (eMidiEventType.MIDIEvents.contains(eventType)) {
        event = TimedEvent(type: eventType, deltaTime: delta, reader: processor);
    }
    else {
        event = GenericMidiEvent(type: eventType, reader: processor);
    }
    return event!;
}

public func peakNextByte(buffer: ByteBuffer) -> UInt8 {

    var byte: UInt8 = 0;

    buffer.mark();
    byte = buffer.getUInt8();
    buffer.reset();

    return byte;
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
        if (eventType == .endOfTrack) {
            print(kOrpheeDebug_procHelpers_reachedEndOfTrack);
        }
        return eventType;
    }
    if let eventType = eMidiEventType.getMIDIEventFor(statusByte) {
        return eventType;
    }
    if (statusByte & 0x80 != 0) {
        return eMidiEventType.unknown;
    }
    return eMidiEventType.runningStatus;
}
