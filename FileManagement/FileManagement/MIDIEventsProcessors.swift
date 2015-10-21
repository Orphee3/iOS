//
//  MIDIEventsProcessors.swift
//  FileManagement
//
//  Created by Massil on 10/04/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation


public func processUnknownEvent(data: ByteBuffer) -> [UInt32] {

    var stop: Bool = false;
    var event: [UInt32] = [];

    while (!stop) {

        data.mark();

        let byte = data.getUInt8();
        let eventType = processStatusByte(byte);
        if (isSysResetByte(byte)
            || eventType != eMidiEventType.runningStatus
            || !data.hasRemaining) {

            stop = true;
            if (eMidiEventType.MIDIEvents.contains(eventType)) {

                data.reset();
            }
        }
        event.append(UInt32(byte));
    }
    return event;
}
