//
//  MIDIWriter.swift
//  FileManagement
//
//  Created by Massil on 25/03/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit

/// Class MIDIWriter implements pOutputManager
///
///
public class MIDIWriter: pOutputManager {

    var handle: NSFileHandle?;

    public init(path: String) {

        self.handle = NSFileHandle(forWritingAtPath: path);
        if (self.handle == nil) {
            print("\n\nMIDIWriter init failed.\n\n");
        }
    }

    public func write(data: NSData) -> Bool {

        if let hdl = handle {
            hdl.writeData(data);
            print("\n\nMIDIWriter write succeeded.\n\n");
            return true;
        }
        print("\n\nMIDIWriter write failed.\n\n");
        return false;
    }
}
