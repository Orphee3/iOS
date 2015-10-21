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
        if let _ = self.handle {
            print("All good!");
        } else {
            print("path error on: \(path)");
        }
    }

    public func readAllData() -> NSData {


        let data = handle!.readDataToEndOfFile();
        handle!.seekToFileOffset(0);
        return data;
    }

    public func read(size size: UInt) -> NSData {

        let data = handle!.readDataOfLength(Int(size));
        if handle!.offsetInFile >= getEOFposition() {
            handle!.seekToFileOffset(0);
        }
        return data;
    }

    func getEOFposition() -> UInt64 {
        let curOffset = handle!.offsetInFile;
        let endOffset = handle!.seekToEndOfFile();
        handle!.seekToFileOffset(curOffset);
        return endOffset;
    }

    deinit {
        handle!.closeFile();
        handle = nil;
    }
}
