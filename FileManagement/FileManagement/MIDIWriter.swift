//
//  MIDIWriter.swift
//  FileManagement
//
//  Created by Massil on 25/03/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit
import MIDIToolbox

/// Class MIDIWriter implements pOutputManager
///
///
public class MIDIWriter: pOutputManager {

    /// The handle for the managed file.
    var handle: NSFileHandle?;

    ///  Default init method.
    ///
    ///  - parameter path: The path to the MIDI file to write.
    ///
    ///  - returns: An initialized MIDIWriter instance.
    public init(path: String) {

        self.handle = NSFileHandle(forWritingAtPath: path);
        if (self.handle == nil) {
            print(kOrpheeDebug_MIDIWriter_initFailed);
        }
    }

    ///    Writes the given data to the target.
    ///
    ///    - parameter data: The data to write out.
    ///
    ///    - returns: `true` on success, `false` otherwise.
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
