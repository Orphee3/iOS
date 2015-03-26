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
class MIDIReader: InputManager {

    var handle: NSFileHandle?;

    init(path: String) {

        self.handle = NSFileHandle(forReadingAtPath: path);
    }

    func readAllData() -> NSData {

        return NSData(contentsOfFile: "")!;
    }

    func read(#size: UInt) -> NSData {

        return NSData(contentsOfFile: "")!;
    }
}