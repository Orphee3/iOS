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

    typealias dataSource;

    var type: eMidiEventType { get };
    var data: [UInt32]? { get set };

    func readData(rawData: dataSource);
}


