//
//  MIDIMetaEventsProcessors.swift
//  FileManagement
//
//  Created by JohnBob on 14/07/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation

///  Midi data processing related exceptions.
///
///  - dataIsInvalidLengthForEventType
///  - readBeyondLimit
public enum processingError: ErrorType {
    ///  Raised when the size of the data associated to an event is considered invalid.
    ///
    ///  - parameter length: The invalid length.
    ///
    ///  - returns: A processingError value.
    case dataIsInvalidLengthForEventType(eMidiEventType, length: Int, String)
    ///  Raised when the read size exceeds the buffer's limit.
    ///
    ///  - parameter bufferSize:     The buffer's total size.
    ///  - parameter remainingBytes: The number of Bytes left in the buffer.
    ///  - parameter readSize:       The size in Bytes of the read operation.
    ///
    ///  - returns: A processingError value.
    case readBeyondLimit(bufferSize: Int, remainingBytes: Int, readSize: Int)
}

///  Processes a "time signature" event given a data source.
///
///  - parameter data: The data source containing the unknown event and its associated data.
///
///  - throws: `processingError.dataIsInvalidLengthForEventType`
///
///  - returns: A Byte array containing the parsed data.
public func processTimeSigEvent(data: ByteBuffer) throws -> [UInt32] {

    let dataLength = data.getUInt8();

    if (isExpectedLength(dataLength, expected: UInt8(kMIDIEventMaxSize_timeSignature))) {

        var result: [UInt32] = [UInt32(data.getUInt8())];
        result.append(UInt32( pow(2, Double(data.getUInt8()))));
        result.append(UInt32(data.getUInt8()));
        result.append(UInt32(data.getUInt8()));

        return result;
    }
    throw processingError.dataIsInvalidLengthForEventType(eMidiEventType.timeSignature, length: Int(dataLength), kOrpheeDebug_metaEventProc_timeSigDataInvalidLength);
}

///  Processes a "set tempo" event given a data source.
///
///  - parameter data: The data source containing the unknown event and its associated data.
///
///  - throws: `processingError.dataIsInvalidLengthForEventType`
///
///  - returns: A Byte array containing the parsed data.
public func processTempoEvent(data: ByteBuffer) throws -> [UInt32] {

    let dataLength = data.getUInt8();

    if (isExpectedLength(dataLength, expected: UInt8(kMIDIEventMaxSize_setTempo))) {

        var bpm: UInt32 = 0;

        bpm = UInt32(data.getUInt8());
        bpm <<= 8;
        bpm |= UInt32(data.getUInt8());
        bpm <<= 8;
        bpm |= UInt32(data.getUInt8());
        return [60_000_000 / bpm];
    }
    throw processingError.dataIsInvalidLengthForEventType(eMidiEventType.setTempo, length: Int(dataLength), kOrpheeDebug_metaEventProc_setTempoDataInvalidLength);
}

///  Processes an "End Of Track" event given a data source.
///
///  - parameter data: The data source containing the unknown event and its associated data.
///
///  - throws: `processingError.dataIsInvalidLengthForEventType`
///
///  - returns: An empty Byte array.
public func processEndOfTrack(data: ByteBuffer) throws -> [UInt32] {

    let length = data.getUInt8()
    guard length == 0 else {
        throw processingError.dataIsInvalidLengthForEventType(eMidiEventType.endOfTrack, length: Int(length), "");
    }
    return [];
}
