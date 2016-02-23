//
//  MidiEvents.swift
//  FileManagement
//
//  Created by Massil on 10/04/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit

/// Realisation of pMidiEvent allowing for Equality checks.
public class BaseMidiEvent: pMidiEvent, CustomStringConvertible {
    /// The event type.
    public var type: eMidiEventType;
    /// A String description of the event.
    public var description: String = "\n";

    /// The data associated with the event.
    public var data: [UInt32]! {
        didSet {
            self.description = String(format: "\n\t0x%X : ", type.rawValue) + self.data!.description
        }
    }

    ///  init
    ///
    ///  - parameter type: The type of event.
    ///
    ///  - returns: An initialized instance of BaseMidiEvent.
    init(type: eMidiEventType) {
        self.type = type;
    }
}

/** BasicMidiEvent realizes pTimedMidiEvent and Printable

*/
public class BasicMidiEvent<T>: BaseMidiEvent, pMidiEventWithReader {

    public typealias dataSource = T;

    /// The closure used for reading the event associated data.
    public var dataReader: (rawData: T) throws -> [UInt32];

    ///  init
    ///
    ///  - parameter type:      The event type.
    ///  - parameter reader:    The closure used for reading the event associated data.
    ///
    ///  - returns: returns an initialized instance of BasicMidiEvent.
    public init(type: eMidiEventType, reader: (rawData: T) throws -> [UInt32]) {

        self.dataReader = reader;
        super.init(type: type);
    }

    ///  Reads data from a given data source using `dataReader` closure.
    ///
    ///  - parameter data: Data source to read from.
    ///
    ///  - throws: `processingError` values.
    ///
    ///  - returns: An initialized `pMidiEvent` instance with `data` property updated.
    public func readData(data: T) throws -> pMidiEvent {

        self.data = try dataReader(rawData: data);
        return self;
    }
}

extension BaseMidiEvent :Equatable {}

///  Basic equality check for BaseMidiEvent.
///
///  - parameter lhs: A BaseMidiEvent.
///  - parameter rhs: Another BaseMidiEvent.
///
///  - returns: `true` if both instances are of the same (sub)type, describe the same event type and contain the same data
public func ==(lhs: BaseMidiEvent, rhs: BaseMidiEvent) -> Bool {
    return (lhs.dynamicType == rhs.dynamicType) && (lhs.data == rhs.data) && (lhs.type == rhs.type);
}
