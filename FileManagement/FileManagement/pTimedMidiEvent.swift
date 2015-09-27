//
//  pTimedMidiEvent.swift
//  FileManagement
//
//  Created by JohnBob on 14/07/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation

/** pTimedMidiEvent protocol

*/
public protocol pTimedMidiEvent: pMidiEvent {

    var deltaTime: UInt32 { get };

    init(type: eMidiEventType, deltaTime: UInt32, reader: (rawData:dataSource) -> [UInt32]);
}