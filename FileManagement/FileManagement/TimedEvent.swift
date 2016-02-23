//
//  TimedEvent.swift
//  FileManagement
//
//  Created by Massil on 15/07/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit

/** TimedEvent realizes pTimedMidiEvent and specialises GenericMidiEvent

*/
public class TimedEvent<T>: GenericMidiEvent<T>, pTimedMidiEvent {

    public var deltaTime: UInt32 = 0;

    required public init(type: eMidiEventType, deltaTime: UInt32, reader: (rawData: T) -> [UInt32]) {

        super.init(type: type, reader: reader);

        self.deltaTime = deltaTime;
        self.description += "delta = \(deltaTime),";
    }
}
