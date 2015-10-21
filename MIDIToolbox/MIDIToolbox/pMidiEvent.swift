//
//  pMidiEvent.swift
//  FileManagement
//
//  Created by JohnBob on 10/04/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation

///  Generic MIDI event
public protocol pMidiEvent {

    /// The event type.
    var type: eMidiEventType { get };
    
    /// The data associated with the event.
    var data: [UInt32]! { get set };
}

///  Generic MIDI event with the ability to read data from a generic data source.
public protocol pMidiEventWithReader: pMidiEvent {

    typealias dataSource;

    ///  Reads data from a given data source.
    ///
    ///  - parameter rawData: Data source to read from.
    ///
    ///  - throws: `processingError` values.
    ///
    ///  - returns: An initialized `pMidiEvent` instance with `data` property updated.
    func readData(rawData: dataSource) throws -> pMidiEvent;
}
