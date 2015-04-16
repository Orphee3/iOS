//
//  MIDIFileManager.swift
//  FileManagement
//
//  Created by Massil on 25/03/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit

/// Class MIDIFileManager implements FormattedFileManager
///
/// A file manager dedicated to MIDI files.
class MIDIFileManager: FormattedFileManager {

    /// The formatted file type's standard extension.
    class var ext: String {
        return "mid";
    };

    /// The formatted file type's standard storing directory.
    class var store: String {
        return "/Users/Massil/Desktop";
    }

    /// The object used to write to the managed file.
    lazy var writer: OutputManager = MIDIWriter(path: self.path);

    /// The object used to read from the managed file.
    lazy var reader: InputManager = MIDIReader(path: self.path);

    /// The name to the managed file.
    var name: String;

    var path: String {
        get {
            return (MIDIFileManager.store + "/" + self.name + "." + MIDIFileManager.ext)
        }
    }

    required init(name: String) {

        self.name = name;
    }

    func createFile(name: String?, header: [String : AnyObject]?) -> Bool {

        if (name != nil) {
            self.name = name!;
        }

        NSFileManager.defaultManager().createFileAtPath(self.path, contents: nil, attributes: nil);

        var midiFile = MIDIFileCreator();
        midiFile.addTrack([ [45, 86, 74], [], [45, 86, 74], [45, 86, 74], [45, 86, 74], [], [], [], [45, 86, 74] ])
        return writer.write(midiFile.dataForFile());
    }

    func deleteFile() {

    }
	
}