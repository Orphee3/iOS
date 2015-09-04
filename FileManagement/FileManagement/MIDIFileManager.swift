//
//  MIDIFileManager.swift
//  FileManagement
//
//  Created by Massil on 25/03/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit
import AudioToolbox

let kOrpheeFile_extension: String = "mid";
let kOrpheeFile_store: String = "/Users/Massil/Desktop";

let kOrpheeFileContent_tracks: String = "TRACKS";

/// Class MIDIFileManager implements pFormattedFileManager
///
/// A file manager dedicated to MIDI files.
public class MIDIFileManager<T where T: pMIDIByteStreamBuilder>: pFormattedFileManagerWithDataCreator {

    public typealias dataCreatorType = T;

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

    public var dataCreator: pMIDIByteStreamBuilder!;

    /// The name to the managed file.
    public var name: String;

    public var path: String {
        get {
            return (MIDIFileManager.store + "/" + self.name + "." + MIDIFileManager.ext)
        }
    }

    public required init(name: String) {

        self.name = name;
    }

    public func createFile(name: String?, content: [String : Any]?) -> Bool {

        if (name != nil) {
            self.name = name!;
        }

        NSFileManager.defaultManager().createFileAtPath(self.path, contents: nil, attributes: nil);

        if let tracks: Any = content?[kOrpheeFileContent_tracks] {
            let trackList = tracks as! [Int : [[MIDINoteMessage]]];
            dataCreator = dataCreatorType(trkNbr: UInt16(trackList.count), ppqn: 384);
            dataCreator.buildMIDIBuffer();
            for (_, track) in trackList {
                dataCreator.addTrack(track);
            }
        }
        return writer.write(dataCreator.toData());
    }

    public func readFile(name: String?) -> [String : AnyObject]? {

        if (name != nil) {
            self.name = name!;
        }

        let parser = MIDIDataParser(data: reader.readAllData());
        return [kOrpheeFileContent_tracks : parser.parseTracks()];
    }

    public func deleteFile() {

    }
}
