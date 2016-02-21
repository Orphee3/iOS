//
//  DefaultReader.swift
//  FileManagement
//
//  Created by Massil on 25/03/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit

public enum DefaultReaderError: ErrorType {
    case InitFailed(String)
}

/// Class DefaultReader implements pInputManager
///
///
public class DefaultReader: pInputManager {

    /// The handle for the managed file.
    var handle: NSFileHandle?;

    ///  Default init method.
    ///
    ///  - parameter path: The path to the file to read.
    ///
    ///  - returns: An initialized DefaultReader instance.
    public init(path: String) throws {

        self.handle = NSFileHandle(forReadingAtPath: path);
        guard let _ = self.handle else {
            throw DefaultReaderError.InitFailed("DefaultReader init failed");
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
        if let _ = handle {
            handle!.closeFile();
            handle = nil;
        }
    }
}
