//
//  MIDIFileManager.swift
//  FileManagement
//
//  Created by Massil on 25/03/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit
import AudioToolbox
import MIDIToolbox

/// The default extension for files created by the Orphee application
public let kOrpheeFile_extension: String = "mid";

/// The default directory where Orphee files are kept.
public let kOrpheeFile_store: String = NSHomeDirectory() + "/Documents";

/// The key coding for the tracks array contained in the "content" dictionnary
/// used by `MidiFileManager`'s `writeToFile` and `readFile` methodes.
/// 
/// - todo: Make an enum with all accepted values.
public let kOrpheeFileContent_tracks: String = "TRACKS";

/// The key coding for the track's information dictionary contained in the "content" dictionnary
/// used by `MidiFileManager`'s `writeToFile` and `readFile` methodes.
///
/// - todo: Make an enum with all accepted values.
public let kOrpheeFileContent_trackInfo: String = "TRACKINFO";

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

    /// The path to the managed MIDI file.
    public var path: String {
        get {
            return (MIDIFileManager.store + "/" + self.name)
        }
    }

    ///  Default init method for MIDIFileManager.
    ///
    ///  - parameter name: The name of the file to manage.
    ///  Do not give a path string. `kOrpheeFile_store` is used.
    ///
    ///  - returns: An initialized instance of MIDIFileManager.
    public required init(name: String) {
        self.name = name;
    }

    ///  Creates a new MIDI file.
    ///
    ///  - parameter name: If provided, overrides and replaces the `name` property.
    ///
    ///  - returns: `true` if the operation was successful or if the item already exists, `false` otherwise.
    public func createFile(name: String? = nil) -> Bool {
        if (name != nil) {
            self.name = name!;
        }
        return NSFileManager.defaultManager().createFileAtPath(self.path, contents: nil, attributes: nil);
    }

    ///  Formats and write the given dictionnary to the managed MIDI file.
    ///
    ///  - parameter content:         A dictionnary containing instructions to create a MIDI file.
    ///  - parameter dataBuilderType: The type of the `pMIDIByteStreanBuilder`-conforming object in charge of building the given file.
    ///
    ///  - returns: `true` on success, `false otherwise.
    public func writeToFile<T where T: pMIDIByteStreamBuilder>(content content: [String : Any]?, dataBuilderType: T.Type) -> Bool {
        guard let input		= content,
              let trackInfo = input[kOrpheeFileContent_trackInfo] as? [Int : [String : Any]],
              let trackList	= input[kOrpheeFileContent_tracks] as? [Int : [[MIDINoteMessage]]]
              else {
                return false;
        }
        let dataCreator = dataBuilderType.init(trkNbr: UInt16(trackList.count), ppqn: 384);
        dataCreator.buildMIDIBuffer();

        for (idx, track) in trackList {
            var chanMsg = MIDIChannelMessage(status: eMidiEventType.programChange.rawValue | UInt8(idx), data1: 0, data2: 0, reserved: 0);
            if let trkInfo = trackInfo[idx],
               let patchID = trkInfo["PATCH"] as? Int {
                chanMsg.data1 = UInt8(patchID);
            }
            dataCreator.addTrack(track, prog: chanMsg)
        }
        return writer.write(dataCreator.toData())
    }

    ///  Reads the managed MIDI file and produces a formatted dictionnary describing the content.
    ///
    ///  - returns: The formatted dictionnary describing the file's content.
    public func readFile() -> [String : Any]? {
        let parser = MIDIDataParser(data: reader.readAllData());
        var content = [kOrpheeFileContent_tracks : parser.parseTracks() as Any];
        var trackInfo = [Int : Any]()
        for track in parser.tracks {
            trackInfo[Int(track.trackNbr) ] = ["PATCH" : track.instrumentID]
        }
        content[kOrpheeFileContent_trackInfo] = trackInfo;
        return content;
    }

    ///  Deletes the managed MIDI file.
    public func deleteFile() {
    }

    ///  Checks if the given file name has the expected file extension.
    ///
    ///  - parameter name: The file name to check.
    ///  - parameter fExt: The expected file extension.
    ///
    ///  - returns:     `true` if the file has the expected extension, `false` otherwise.
    ///  - attention:   The expected extension must not start with a "."
    class func formatFileName(name: NSString, fileExtension fExt: String) -> Bool {
        return name.pathExtension == fExt;
    }
}
