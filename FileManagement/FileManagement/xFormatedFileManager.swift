//
// Created by John Bobington on 15/12/2015.
// Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation

public extension pFormattedFileManager {

    /// The path to the managed MIDI file.
    public var path: String {
        get {
            return (Self.store + "/" + self.name)
        }
    }

    public func createFile(name: String? = nil) -> Bool {
        if let name = name {
            self.name = name;
        }
        formatFileName();
        return NSFileManager.defaultManager().createFileAtPath(self.path, contents: nil, attributes: nil);
    }

    public func deleteFile() {
        do {
            try NSFileManager.defaultManager().removeItemAtPath(self.path)
        } catch let error {
            print("Error while removing file `\(self.path)`: \(error)")
        }
    }

    public func formatFileName() -> Bool {
        let nm: NSString = self.name;
        if (nm.pathExtension != Self.ext) {
            self.name += ".\(Self.ext)";
        }
        return true
    }

    public func readFile() -> [String : Any]? {
        let data = reader.readAllData()
        return Self.parseData(data)
    }

    public func getFileData() -> NSData {
        return self.reader.readAllData()
    }
}
