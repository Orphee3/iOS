//
//  MIDIEventsProcessorsHelpers.swift
//  FileManagement
//
//  Created by JohnBob on 14/07/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation

public enum bufferErrors: ErrorType {

    case readBeyondLimit(bufferSize: Int, remainingBytes: Int, readSize: Int)
}

public func isExpectedLength(length: UInt8, expected: UInt8) -> Bool {

    return length == expected;
}

public func buildMIDIEventProcessor(event: eMidiEventType, chan: UInt8?) -> (data: ByteBuffer) throws -> [UInt32] {

    switch event {
    case .noteOn, .noteOff, .programChange:
        return { (data: ByteBuffer) -> [UInt32] in

            var values: [UInt8] = [chan!];
            values += data.getUInt8(eMidiEventType.sizeof[event]! - 1);
            return values.map() { UInt32($0); }
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

public func makeMidiEvent(eventType: eMidiEventType, delta: Int = 0, chan: UInt8? = nil) -> BasicMidiEvent<ByteBuffer> {

    let event: BasicMidiEvent<ByteBuffer>!;
    let processor = buildMIDIEventProcessor(eventType, chan: chan);

    if (eMidiEventType.allMIDIEvents.contains(eventType)) {
        event = TimedMidiEvent(type: eventType, deltaTime: UInt32(delta), reader: processor);
    }
    else {
        event = BasicMidiEvent(type: eventType, reader: processor);
    }
    return event!;
}

public func isSysResetByte(currentByte: UInt8) -> Bool {

    return currentByte == 0xFF
}

public func getChanForEventType(type: eMidiEventType, fromByte byte: UInt8) throws -> UInt8 {
    guard type != eMidiEventType.unknown && type != eMidiEventType.runningStatus else {
        return 0;
    }
    guard case let ok = try eMidiEventType.isByte(byte, aMidiEventOfType: type) where ok else {
        throw eMidiEventType.eMidiEventTypeErrors.byteIsNotOfGivenType(byte: byte, type: type, "\(byte) is not a \(type) event");
    }
    return (byte ^ type.rawValue);
}

public func peakNextByte(buffer: ByteBuffer) throws -> UInt8 {

    var byte: UInt8 = 0;

    guard buffer.hasRemaining else {
        throw bufferErrors.readBeyondLimit(bufferSize: buffer.capacity, remainingBytes: buffer.remaining, readSize: 1)
    }
    buffer.mark();
    byte = buffer.getUInt8();
    buffer.reset();

    return byte;
}

public func getNextStatusByte(buffer: ByteBuffer, inout isMeta meta: Bool) throws -> UInt8 {

    var iteration = 0;
    let startPos = buffer.position;
    repeat {
        guard buffer.hasRemaining else {
            buffer.position = startPos;
            throw bufferErrors.readBeyondLimit(bufferSize: buffer.capacity, remainingBytes: buffer.remaining, readSize: iteration)
        }
        let readByte = buffer.getUInt8();
        guard readByte == 0x00 || readByte == 0xFF else {
            return readByte;
        }
        meta = isSysResetByte(readByte);
        ++iteration;
    } while (buffer.hasRemaining)
    buffer.position = startPos;
    throw bufferErrors.readBeyondLimit(bufferSize: buffer.capacity, remainingBytes: buffer.remaining, readSize: iteration)
}

public func processStatusByte(statusByte: UInt8, isMeta meta: Bool = false) -> eMidiEventType {

    let eventType: eMidiEventType!;
    do {
        eventType = try eMidiEventType.getMidiEventTypeFor(statusByte, isMeta: meta);
        if (eventType == .endOfTrack) {
            print(kOrpheeDebug_procHelpers_reachedEndOfTrack);
        }
    }
    catch {
        print(error);
        eventType = .unknown;
    }
    return eventType
}

