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

    /// The handle for the managed file.
    var handle: NSFileHandle?;

    ///  Default init method.
    ///
    ///  - parameter path: The path to the MIDI file to read.
    ///
    ///  - returns: An initialized MIDIReader instance.
    public init(path: String) {

        self.handle = NSFileHandle(forReadingAtPath: path);
        if let _ = self.handle {
            print("All good!");
        } else {
            print("path error on: \(path)");
        }
    }

    ///    Reads all the data contained in the given target.
    ///
    ///    - returns: The data that has been read.
    public func readAllData() -> NSData {

        let data = handle!.readDataToEndOfFile();
        handle!.seekToFileOffset(0);
        return data;
    }

    ///    Reads the given number of bytes from the target.
    ///
    ///    - parameter size: The number of bytes to read.
    ///
    ///    - returns: The data that has been read.
    public func read(size size: UInt) -> NSData {

        let data = handle!.readDataOfLength(Int(size));
        if handle!.offsetInFile >= getEOFposition() {
            handle!.seekToFileOffset(0);
        }
        return data;
    }

    ///  Provides the position of the EndOfFile.
    ///
    ///  - returns: The position of EOF.
    func getEOFposition() -> UInt64 {
        let curOffset = handle!.offsetInFile;
        let endOffset = handle!.seekToEndOfFile();
        handle!.seekToFileOffset(curOffset);
        return endOffset;
    }

    ///  Closes the file handler.
    deinit {
        handle!.closeFile();
        handle = nil;
    }
}
