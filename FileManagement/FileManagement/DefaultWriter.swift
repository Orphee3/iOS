//
//  DefaultWriter.swift
//  FileManagement
//
//  Created by Massil on 25/03/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit

public enum DefaultWriterError: ErrorType {
    case InitFailed(String)
}

/// Class DefaultWriter implements pOutputManager
///
///
public class DefaultWriter: pOutputManager {

    /// The handle for the managed file.
    var handle: NSFileHandle?;

    ///  Default init method.
    ///
    ///  - parameter path: The path to the MIDI file to write.
    ///
    ///  - returns: An initialized DefaultWriter instance.
    public init(path: String) throws {

        self.handle = NSFileHandle(forWritingAtPath: path)
        guard let _ = self.handle else {
            throw DefaultWriterError.InitFailed("MIDIWriter init failed.")
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
            return true;
        }
        print(kOrpheeDebug_MIDIWriter_writeFailed);
        return false;
    }
}
