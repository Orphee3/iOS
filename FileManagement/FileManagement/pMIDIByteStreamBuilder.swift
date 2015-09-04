//
//  pMIDIByteStreamBuilder.swift
//  FileManagement
//
//  Created by JohnBob on 14/07/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import AudioToolbox

/// pMIDIByteStreamBuilder protocol:
///
/// Any class building a MIDI byte stream/buffer needs to follow this protocol.
public protocol pMIDIByteStreamBuilder {

    /// The number of tracks to build
    var _trackCount: UInt16 { get };

    /// The time resolution, aka Pulse Per Quarter Note.
    var _timeResolution: UInt16 { get };

    ///    Default initializer.
    ///
    ///    :param: trkNbr The number of tracks the file will contain.
    ///    :param: ppqn   The time resolution, aka Pulse Per Quarter Note.
    ///
    ///    :returns: Initializes the MIDIByteStreamBuilder.
    init(trkNbr: UInt16, ppqn: UInt16);

    func buildMIDIBuffer();

    ///    Builds and adds a track to the MIDI file.
    ///
    ///    :param: notes    The note events in the form of an array of arrays of MIDINoteMessages.
    ///                     Each array contains all the data for every note event sent at deltaTime = array index.
    func addTrack(notes: [[MIDINoteMessage]]);

    ///    Provides the formatted content as NSData.
    ///
    ///    :returns: NSData wrapper for the MIDI byte stream content.
    func toData() -> NSData;
}
