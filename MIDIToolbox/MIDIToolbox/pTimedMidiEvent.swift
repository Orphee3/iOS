//
//  pTimedMidiEvent.swift
//  FileManagement
//
//  Created by JohnBob on 14/07/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation

///  Generic midi event associated with a delta-time value.
public protocol pTimedMidiEvent: pMidiEvent {

    /// The associated delta-time.
    var deltaTime: UInt32 { get };
}

///  Generic midi event associated with a delta-time value with the ability to read data from a generic data source.
public protocol pTimedMidiEventWithReader: pTimedMidiEvent, pMidiEventWithReader {

    ///  init
    ///
    ///  - parameter type:      The event type.
    ///  - parameter deltaTime: The delta-time associated with this event.
    ///  - parameter reader:    The closure used for reading the event associated data.
    ///
    ///  - returns: returns an initialized instance of pTimedMidiEventWithReader.
    init(type: eMidiEventType, deltaTime: UInt32, reader: (rawData:dataSource) -> [UInt32]);
}