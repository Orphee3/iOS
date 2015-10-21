//
//  MidiEvents.swift
//  FileManagement
//
//  Created by Massil on 10/04/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit

public class BaseMidiEvent: pMidiEvent, CustomStringConvertible {
    public var type: eMidiEventType;
    public var description: String = "\n";

    public var data: [UInt32]! {
        didSet {
            self.description = String(format: "\n\t0x%X : ", type.rawValue) + self.data!.description
        }
    }

    init(type: eMidiEventType) {
        self.type = type;
    }
}

/** BasicMidiEvent realizes pTimedMidiEvent and Printable

*/
public class BasicMidiEvent<T>: BaseMidiEvent, pMidiEventWithReader {

    public typealias dataSource = T;

    public var dataReader: (rawData: T) throws -> [UInt32];

    public init(type: eMidiEventType, reader: (rawData: T) throws -> [UInt32]) {

        self.dataReader = reader;
        super.init(type: type);
    }

    public func readData(data: T) throws -> pMidiEvent {

        self.data = try dataReader(rawData: data);
        return self;
    }
}

extension BaseMidiEvent :Equatable {}

public func ==(lhs: BaseMidiEvent, rhs: BaseMidiEvent) -> Bool {
    return (lhs.dynamicType == rhs.dynamicType) && (lhs.data == rhs.data) && (lhs.type == rhs.type);
}
