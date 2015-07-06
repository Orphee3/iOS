//
//  MIDIReader.swift
//  FileManagement
//
//  Created by Massil on 25/03/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit

/// Class MIDIReader implements InputManager
///
/// 
public class MIDIReader: InputManager {

    var handle: NSFileHandle?;

    public init(path: String) {

        self.handle = NSFileHandle(forReadingAtPath: path);
    }

    public func readAllData() -> NSData {

        return handle!.readDataToEndOfFile();
    }

    public func read(#size: UInt) -> NSData {

        return handle!.readDataOfLength(Int(size));
    }
}