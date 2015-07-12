//
//  MidiEventGenerics.swift
//  FileManagement
//
//  Created by Massil on 10/04/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit


public class GenericMidiEvent<T>: MidiEvent, Printable {

    typealias dataSource = T;

    public var type: MidiEventType;
    public var dataReader: (rawData: T) -> [UInt32];

    public var description: String = "\n";

    public var data: [UInt32]? = nil;

    public init(type: MidiEventType, reader: (rawData: T) -> [UInt32]) {

        self.type = type;
        self.dataReader = reader;
    }

    public func readData(data: T) {

        self.data = dataReader(rawData: data);
        description += String(format: "\t0x%X : ", type.rawValue) + self.data!.description;
    }
}


public class TimedEvent<T>: GenericMidiEvent<T>, TimedMidiEvent {

    public var deltaTime: UInt32 = 0;

    required public init(type: MidiEventType, deltaTime: UInt32, reader: (rawData: T) -> [UInt32]) {

        super.init(type: type, reader: reader);
        
        self.deltaTime = deltaTime;
        self.description += "delta = \(deltaTime),";
    }
}