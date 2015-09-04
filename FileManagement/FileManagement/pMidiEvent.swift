//
//  pMidiEvent.swift
//  FileManagement
//
//  Created by JohnBob on 10/04/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation

/** pMidiEvent protocol

*/
public protocol pMidiEvent {

    var type: eMidiEventType { get };
    var data: [UInt32]! { get set };
}

public protocol pMidiEventWithReader: pMidiEvent {

    typealias dataSource;

    func readData(rawData: dataSource) -> pMidiEvent;
}
