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
            print(kOrpheeDebug_MIDIWriter_initFailed);
        }
    }

    public func write(data: NSData) -> Bool {

        if let hdl = handle {
            hdl.writeData(data);
            print(kOrpheeDebug_MIDIWriter_writeOk);
            return true;
        }
        print(kOrpheeDebug_MIDIWriter_writeFailed);
        return false;
    }
}
