//
//  MIDIReader.swift
//  FileManagement
//
//  Created by Massil on 25/03/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit

/// Class MIDIReader implements pInputManager
///
///
public class MIDIReader: pInputManager {

    var handle: NSFileHandle?;

    public init(path: String) {

        self.handle = NSFileHandle(forReadingAtPath: path);
    }

    public func readAllData() -> NSData {

        return handle!.readDataToEndOfFile();
    }

    public func read(size size: UInt) -> NSData {

        return handle!.readDataOfLength(Int(size));
    }
}
