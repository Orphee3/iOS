//
//  MIDIDataParser.swift
//  FileManagement
//
//  Created by Massil on 05/04/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit

/// Class MIDIDataParser
///
/// 
class MIDIDataParser {

    var dataBuffer: ByteBuffer;

    var headerMark: String              = "";
    var headerLength: UInt32            = 0;
    var midiFileType: UInt16            = 0;
    var nbrOfTracks: UInt16             = 0;
    var deltaTickPerQuarterNote: UInt16 = 0;

    init(data: NSData) {

        self.dataBuffer = ByteBuffer(order: LittleEndian(), capacity: data.length);
        data.getBytes(self.dataBuffer.data);

        self.readHeader();
        self.printHeader();
    }

    func readHeader() {
        
        // file header mark
        headerMark = dataBuffer.getUTF8(4);

        // track header length
        headerLength = SwapUInt32(dataBuffer.getUInt32());
        midiFileType = SwapUInt16(dataBuffer.getUInt16());
        nbrOfTracks = SwapUInt16(dataBuffer.getUInt16());
        deltaTickPerQuarterNote = SwapUInt16(dataBuffer.getUInt16());
    }


    private func printHeader() {

        println("\n//////////// FILE DATA /////////////");
        println("Header mark = \(headerMark)");
        println("Header length = \(headerLength)");
        println("midi file type = \(midiFileType)");
        println("number of tracks = \(nbrOfTracks)");
        println("dtTicks/quarter note = \(deltaTickPerQuarterNote)");
        println("////////////////////////////////////\n");
    }
}

func getNextEvent(buffer: ByteBuffer, inout isMetaEvent: Bool) -> UInt8 {

    if (!isMetaEvent) {
        buffer.mark();
    }

    let byte = buffer.getUInt8()

    if (byte == 0xFF || byte == 0) {

        isMetaEvent = isMetaEventByte(byte)
        return getNextEvent(buffer, &isMetaEvent);
    }
    if (!isMetaEvent) {
        buffer.reset();
    }
    return byte;
}

func isMetaEventByte(currentByte: UInt8) -> Bool {

    return currentByte == 0xFF
}

func processStatusByte(statusByte: UInt8) -> MidiEventType {

    if let eventType = MidiEventType(rawValue: statusByte) {
        return eventType;
    }
    for eventType in MidiEventType.MIDIEvents {

        if ((eventType.rawValue & statusByte == eventType.rawValue)
            && (eventType.rawValue ^ statusByte < 0xF)) {

            return eventType;
        }
    }
    return MidiEventType.unknown;
}
