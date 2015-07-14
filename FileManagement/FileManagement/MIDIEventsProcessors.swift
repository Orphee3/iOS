//
//  MIDIEventsProcessors.swift
//  FileManagement
//
//  Created by Massil on 10/04/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation


public func processProgramChange(data: ByteBuffer) -> [UInt32] {

    let channel = data.getUInt8() ^ 0xC0;
    let instruID = data.getUInt8();
    return [UInt32(channel), UInt32(instruID)];
}

public func processNoteOnEvent(data: ByteBuffer) -> [UInt32] {

    let channel = data.getUInt8() ^ 0x90;
    let note = data.getUInt8();
    let velocity = data.getUInt8();
    return [UInt32(channel), UInt32(note), UInt32(velocity)];
}

public func processNoteOffEvent(data: ByteBuffer) -> [UInt32] {

    let channel = data.getUInt8() ^ 0x80;
    let note = data.getUInt8();
    let velocity = data.getUInt8();
    return [UInt32(channel), UInt32(note), UInt32(velocity)];
}


public func processUnknownEvent(data: ByteBuffer) -> [UInt32] {

    var stop: Bool = false;
    var event: [UInt32] = [];

    while (!stop) {

        data.mark();

        let byte = data.getUInt8();
        let eventType = processStatusByte(byte);
        if (isMetaEventByte(byte) || eventType != eMidiEventType.unknown || !data.hasRemaining) {

            stop = true;
            if (contains(eMidiEventType.MIDIEvents, eventType)) {

                data.reset();
            }
        }
        else {
            event.append(UInt32(byte));
        }
    }
    return event;
}
