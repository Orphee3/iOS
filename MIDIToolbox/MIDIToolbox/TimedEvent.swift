//
//  TimedMidiEvent.swift
//  FileManagement
//
//  Created by Massil on 15/07/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit


/** TimedMidiEvent realizes pTimedMidiEvent and specialises BasicMidiEvent

*/
public class TimedMidiEvent<T>: BasicMidiEvent<T>, pTimedMidiEvent {

    /// The associated delta-time.
    public var deltaTime: UInt32 = 0;

    ///  init
    ///
    ///  - parameter type:      The event type.
    ///  - parameter deltaTime: The delta-time associated with this event.
    ///  - parameter reader:    The closure used for reading the event associated data.
    ///
    ///  - returns: returns an initialized instance of pTimedMidiEventWithReader.
 required public init(type: eMidiEventType, deltaTime: UInt32, reader: (rawData: T) throws -> [UInt32]) {

        super.init(type: type, reader: reader);

        self.deltaTime = deltaTime;
        self.description += "delta = \(deltaTime),";
    }
}
