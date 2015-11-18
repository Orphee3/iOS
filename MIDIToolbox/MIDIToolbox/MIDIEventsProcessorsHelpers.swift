//
//  MIDIEventsProcessorsHelpers.swift
//  FileManagement
//
//  Created by JohnBob on 14/07/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation

///  Checks if given length is equal to expected length.
///
///  - parameter length:   Length to verify.
///  - parameter expected: Expected length.
///
///  - returns: `true` if equal, `false` otherwise.
public func isExpectedLength(length: UInt8, expected: UInt8) -> Bool {

    return length == expected;
}

///  Builds and provides event-type specific closures designed to process data from a given data source.
///
///  - parameter event: Event type for which to build an event processor.
///  - parameter chan:  Channel on which the event happened.
///
///  - returns: A closure designed to process data for a given event type.
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

///  Builds BasicMidiEvent objects corresponding to a given type.
///
///  - parameter eventType: The desired event type.
///  - parameter delta:     The delta-time associated to the event, when applicable.
///  - parameter chan:      The channel to which the event belongs, when applicable.
///
///  - returns: An initialized BasicMidiEvent instance.
public func makeMidiEvent(eventType: eMidiEventType, delta: Int = 0, chan: UInt8? = nil) -> BasicMidiEvent<ByteBuffer> {

    let event: BasicMidiEvent<ByteBuffer>!;
    let processor = buildMIDIEventProcessor(eventType, chan: chan);

    if (eMidiEventType.kAllMIDIEvents.contains(eventType)) {
        event = TimedMidiEvent(type: eventType, deltaTime: UInt32(delta), reader: processor);
    }
    else {
        event = BasicMidiEvent(type: eventType, reader: processor);
    }
    return event!;
}

///  Determines if the given Byte is the MIDI SysReset Byte preceding a Meta event.
///
///  - parameter currentByte: The Byte to check.
///
///  - returns: `true` if `currentByte` is a SysReset Byte, `false` otherwise.
public func isSysResetByte(currentByte: UInt8) -> Bool {

    return currentByte == 0xFF
}

///  Extracts the channel from the status Byte, given the event type.
///
///  - parameter type: The event type.
///  - parameter byte: The status Byte from which to extract the channel number.
///
///  - throws: `eMidiEventTypeError.byteIsNotOfGivenType`
///
///  - returns: The channel number.
public func getChanForEventType(type: eMidiEventType, fromByte byte: UInt8) throws -> UInt8 {
    guard type != eMidiEventType.unknown && type != eMidiEventType.runningStatus else {
        return 0;
    }
    guard case let ok = try eMidiEventType.isByte(byte, aMidiEventOfType: type) where ok else {
        throw eMidiEventType.eMidiEventTypeError.byteIsNotOfGivenType(byte: byte, type: type, "\(byte) is not a \(type) event");
    }
    return (byte ^ type.rawValue);
}

///  Provides the next Byte without modifying the given buffer.
///
///  - parameter buffer: The buffer to peak in.
///
///  - throws: `processingError.readBeyondLimit` if the buffer has no remaining Bytes to read.
///
///  - returns: The value of the next Byte in the given buffer.
public func peakNextByte(buffer: ByteBuffer) throws -> UInt8 {

    var byte: UInt8 = 0;

    guard buffer.hasRemaining else {
        throw processingError.readBeyondLimit(bufferSize: buffer.capacity, remainingBytes: buffer.remaining, readSize: 1)
    }
    buffer.mark();
    byte = buffer.getUInt8();
    buffer.reset();

    return byte;
}

///  Reads the given buffer until reaching a non-0 and non-SysReset Byte.
///
///  - parameter buffer: The buffer from which to read.
///  - parameter meta:   This flag is set to `true` when encountering a SysReset Byte.
///
///  - throws: `processingError.readBeyondLimit`
///
///  - returns: The next non-0, non-SysReset Byte.
public func getNextStatusByte(buffer: ByteBuffer, inout isMeta meta: Bool) throws -> UInt8 {

    var iteration = 0;
    let startPos = buffer.position;
    repeat {
        guard buffer.hasRemaining else {
            buffer.position = startPos;
            throw processingError.readBeyondLimit(bufferSize: buffer.capacity, remainingBytes: buffer.remaining, readSize: iteration)
        }
        let readByte = buffer.getUInt8();
        guard readByte == 0x00 || readByte == 0xFF else {
            return readByte;
        }
        meta = isSysResetByte(readByte);
        ++iteration;
    } while (buffer.hasRemaining)
    buffer.position = startPos;
    throw processingError.readBeyondLimit(bufferSize: buffer.capacity, remainingBytes: buffer.remaining, readSize: iteration)
}

///  Provides the event type corresponding to given Byte.
///
///  - parameter statusByte: The Byte to process.
///  - parameter meta:       If `true`, `statusByte` is processed as a Meta event's status Byte.
///							 If `false`, `statusByte` is processed as a MIDI event's status Byte.
///
///  - returns: The event type corresponding to the given Byte.
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

