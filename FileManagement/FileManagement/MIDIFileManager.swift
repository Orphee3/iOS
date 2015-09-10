//
//  MIDIFileManager.swift
//  FileManagement
//
//  Created by Massil on 25/03/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit
import AudioToolbox

public let kOrpheeFile_extension: String = "mid";
public let kOrpheeFile_store: String = NSHomeDirectory() + "/Documents";

public let kOrpheeFileContent_tracks: String = "TRACKS";

/// Class MIDIFileManager implements pFormattedFileManager
///
/// A file manager dedicated to MIDI files.
public class MIDIFileManager: pFormattedFileManager {

    /// The formatted file type's standard extension.
    public static var ext: String {
        return kOrpheeFile_extension;
    };

    /// The formatted file type's standard storing directory.
    public static var store: String {
        return kOrpheeFile_store;
    }

    /// The object used to write to the managed file.
    public lazy var writer: pOutputManager = MIDIWriter(path: self.path);

    /// The object used to read from the managed file.
    public lazy var reader: pInputManager = MIDIReader(path: self.path);

    /// The name to the managed file.
    public var name: String;

    public var path: String {
        get {
            return (MIDIFileManager.store + "/" + self.name)
        }
    }

    public required init(name: String) {
        self.name = name;
    }

    public func createFile(name: String? = nil) -> Bool {
        if (name != nil) {
            self.name = name!;
        }
        return NSFileManager.defaultManager().createFileAtPath(self.path, contents: nil, attributes: nil);
    }

    public func writeToFile<T where T: pMIDIByteStreamBuilder>(content content: [String : Any]?, dataBuilderType: T.Type) -> Bool {
        guard let input		= content,
              let tracks	= input[kOrpheeFileContent_tracks],
              let trackList	= tracks as? [Int : [[MIDINoteMessage]]]
              else {
                return false;
        }
        let dataCreator = dataBuilderType.init(trkNbr: UInt16(trackList.count), ppqn: 384);
        dataCreator.buildMIDIBuffer();

        for (_, track) in trackList {
            dataCreator.addTrack(track);
        }
        return writer.write(dataCreator.toData())
    }

    public func readFile() -> [String : AnyObject]? {
        let parser = MIDIDataParser(data: reader.readAllData());
        return [kOrpheeFileContent_tracks : parser.parseTracks()];
    }

    public func deleteFile() {

    }
}
