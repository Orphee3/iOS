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


public enum eOrpheeFileContent: String {
    case Tracks      = "TRACKS"
    case TracksInfos = "TRACKSINFO"
    case PatchID     = "PATCH"
}
/// The default extension for files created by the Orphee application
public let kOrpheeFile_extension: String = "mid";

/// The default directory where Orphee files are kept.
public let kOrpheeFile_store: String = NSHomeDirectory() + "/Documents";

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
    public lazy var writer: pOutputManager = try! MIDIWriter(path: self.path);

    /// The object used to read from the managed file.
    public lazy var reader: pInputManager = try! MIDIReader(path: self.path);

    /// The name to the managed file.
    public var name: String;

    ///  Default init method for MIDIFileManager.
    ///
    ///  - parameter name: The name of the file to manage.
    ///  Do not give a path string. `kOrpheeFile_store` is used.
    ///
    ///  - returns: An initialized instance of MIDIFileManager.
    public required init(name: String) {
        self.name = name;
    }

    ///  Formats and write the given dictionnary to the managed MIDI file.
    ///
    ///  - parameter content:         A dictionnary containing instructions to create a MIDI file.
    ///  - parameter dataBuilderType: The type of the `pMIDIByteStreanBuilder`-conforming object in charge of building the given file.
    ///
    ///  - returns: `true` on success, `false otherwise.
    public func writeToFile<T where T: pMIDIByteStreamBuilder>(content content: [String : Any]?, dataBuilderType: T.Type) -> Bool {
        guard let input		= content,
              let trackInfo = input[eOrpheeFileContent.TracksInfos.rawValue] as? [Int : [String : Any]],
              let trackList	= input[eOrpheeFileContent.Tracks.rawValue] as? [Int : [[MIDINoteMessage]]]
              else {
                return false;
        }
        print(input)
        let dataCreator = dataBuilderType.init(trkNbr: 0, ppqn: 0, timeSig: (4, 4), bpm: 180);
        dataCreator.buildMIDIBuffer();

        for idx in 0..<trackList.count {
            let track = trackList[idx]!
            var chanMsg = MIDIChannelMessage(status: eMidiEventType.programChange.rawValue | UInt8(idx), data1: 0, data2: 0, reserved: 0);
            if let trkInfo = trackInfo[idx],
                let patchID = trkInfo[eOrpheeFileContent.PatchID.rawValue] as? Int {
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
        var tracks = parser.parseTracks()
        for (key, track) in tracks {
            if track.count == 0 {
                tracks.removeValueForKey(key)
            }
        }
        var content = [eOrpheeFileContent.Tracks.rawValue : tracks as Any];
        var trackInfo = [Any]()
        for track in parser.tracks {
            trackInfo.insert([eOrpheeFileContent.PatchID.rawValue : track.instrumentID], atIndex: Int(track.trackNbr))
            print(trackInfo)
        }
        content[eOrpheeFileContent.TracksInfos.rawValue] = trackInfo;
        return content;
    }
}
