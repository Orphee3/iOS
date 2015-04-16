//
//  MidiEventGenerics.swift
//  FileManagement
//
//  Created by Massil on 10/04/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit


class GenericMidiEvent<T>: MidiEvent, Printable {

    typealias dataSource = T;

    var type: MidiEventType;
    var dataReader: (rawData: T) -> [UInt32];

    var description: String = "\n";

    var data: [UInt32]? = nil;

    init(type: MidiEventType, reader: (rawData: T) -> [UInt32]) {

        self.type = type;
        self.dataReader = reader;
    }

    func readData(data: T) {

        self.data = dataReader(rawData: data);
        description += String(format: "\t0x%X : ", type.rawValue) + self.data!.description;
    }
}


class TimedEvent<T>: GenericMidiEvent<T>, TimedMidiEvent {

    var deltaTime: UInt32 = 0;

    required init(type: MidiEventType, deltaTime: UInt32, reader: (rawData: T) -> [UInt32]) {

        super.init(type: type, reader: reader);
        
        self.deltaTime = deltaTime;
        self.description += "delta = \(deltaTime),";
    }
}