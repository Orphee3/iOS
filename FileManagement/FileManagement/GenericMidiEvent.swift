//
//  MidiEvents.swift
//  FileManagement
//
//  Created by Massil on 10/04/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit

/** GenericMidiEvent realizes pTimedMidiEvent and Printable

*/
public class GenericMidiEvent<T>: pMidiEventWithReader, CustomStringConvertible {

    public typealias dataSource = T;

    public var type: eMidiEventType;
    public var dataReader: (rawData: T) -> [UInt32];

    public var description: String = "\n";

    public var data: [UInt32]! {
        didSet {
            self.description = String(format: "\n\t0x%X : ", type.rawValue) + self.data!.description
        }
    }

    public init(type: eMidiEventType, reader: (rawData: T) -> [UInt32]) {

        self.type = type;
        self.dataReader = reader;
    }

    public func readData(data: T) -> pMidiEvent {

        self.data = dataReader(rawData: data);
        return self;
    }
}
