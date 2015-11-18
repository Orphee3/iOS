//
//  MIDIEventsProcessors.swift
//  FileManagement
//
//  Created by Massil on 10/04/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation

///  Processes an unknown or unsupported event given a data source.
///
///  - parameter data: The data source containing the unknown event and its associated data.
///
///  - returns: A Byte array containing all parsed data.
public func processUnknownEvent(data: ByteBuffer) -> [UInt32] {
    
    var stop: Bool = false
    var event: [UInt32] = []
    var firstIteration = true
    var meta = false
    
    while (!stop && data.hasRemaining) {
        
        data.mark();
        
        let byte = data.getUInt8();
        if (isSysResetByte(byte)) {
            if (firstIteration) {
                meta = true;
                event.append(UInt32(byte));
            }
            else {
                stop = true;
                data.reset();
            }
        }
        else {
            
            let eventType = processStatusByte(byte, isMeta: meta);
            
            event.append(UInt32(byte));
            meta = false
        }
        firstIteration = false;
    }
    return event;
}
