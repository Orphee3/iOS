//
//  MIDIMetaEventsProcessors.swift
//  FileManagement
//
//  Created by JohnBob on 14/07/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation

public func processTimeSigEvent(data: ByteBuffer) -> [UInt32] {

    let dataLength = data.getUInt8();

    if (isExpectedLength(dataLength, expected: UInt8(kMIDIEventMaxSize_timeSignature))) {

        var result: [UInt32] = [UInt32(data.getUInt8())];
        result.append(UInt32( pow(2, Double(data.getUInt8()))));
        result.append(UInt32(data.getUInt8()));
        result.append(UInt32(data.getUInt8()));

        return result;
    }
    debugPrint(kOrpheeDebug_metaEventProc_timeSigDataInvalidLength);
    return [];
}

public func processTempoEvent(data: ByteBuffer) -> [UInt32] {

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
    debugPrint(kOrpheeDebug_metaEventProc_setTempoDataInvalidLength);
    return [];
}

public func processEndOfTrack(data: ByteBuffer) -> [UInt32] {

    // No data to process actually...
    return [UInt32(data.getUInt8())];
}
