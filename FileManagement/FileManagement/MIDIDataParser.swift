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
public class MIDIDataParser {

    public struct Track {

        var dataBuffer: ByteBuffer;
        var trackNbr: UInt16;
        var trackLength: UInt32       = 0;

        /// Track configuration
        var nbrOf32ndNotePerBeat: UInt32 = 0;
        var channel: UInt32              = 0;
        var clockTicksPerPulse: UInt32   = 0;
        var instrumentID: Int            = 0;
        var quarterNotePerMinute: UInt32 = 0;
        var signature: (UInt32, UInt32)  = (0, 0);

        var midiEvents: [GenericMidiEvent<ByteBuffer>] = [];

        init(trackData: ByteBuffer, trackNbr: UInt16) {

            self.dataBuffer = trackData;
            self.trackNbr = trackNbr;
            self.readHeader();
            self.readInstrument();
            self.readNoteEvents();
            self.processReadData();
            self.printConfiguration();
        }

        mutating func readHeader() {

            // file header mark
            dataBuffer.getUTF8(4);

            // track header length
            trackLength = SwapUInt32(dataBuffer.getUInt32());

            // track time signature (stored as UInt32)
            var meta = false;
            var nextEvent = processStatusByte(getNextEvent(dataBuffer, &meta));
            midiEvents.append(makeMidiEvent(delta: 0, eventType: nextEvent, buffer: dataBuffer));

            // track tempo (stored as UInt32)
            nextEvent = processStatusByte(getNextEvent(dataBuffer, &meta));
            midiEvents.append(makeMidiEvent(delta: 0, eventType: nextEvent, buffer: dataBuffer));
        }

        mutating func readInstrument() {

            var meta = false;
            var nextEvent = processStatusByte(getNextEvent(dataBuffer, &meta));
            midiEvents.append(makeMidiEvent(delta: 0, eventType: nextEvent, buffer: dataBuffer));
        }

        mutating func readNoteEvents() {

            var nextEvent = MidiEventType.unknown;
            while (dataBuffer.hasRemaining && nextEvent != MidiEventType.endOfTrack) {

                var deltaTime = readTimeStamp();
                var meta = false;
                nextEvent = processStatusByte(getNextEvent(dataBuffer, &meta));
                midiEvents.append(makeMidiEvent(delta: UInt32(deltaTime), eventType: nextEvent, buffer: dataBuffer));
            }
        }

        func readTimeStamp() -> Int {

            var result: Int = 0;

            while (true) {

                let currentByte: UInt8 = dataBuffer.getUInt8();

                if (currentByte & 0x80 != 0) {
                    result += Int(currentByte & 0x7f);
                    result <<= 7;
                }
                else {
                    return result + Int(currentByte); // currentByte is the last byte
                }
            }
        }

        mutating func processReadData() {

            var timeSigEvents = midiEvents.filter { $0.type == MidiEventType.timeSignature };
            var tempoSigs = midiEvents.filter { $0.type == MidiEventType.setTempo };

            if (timeSigEvents.count > 0) {

                let data: [UInt32] = timeSigEvents[0].data!;

                signature = (data[0], data[1]);
                clockTicksPerPulse = data[2];
                nbrOf32ndNotePerBeat = data[3];
            }
            else {
                signature = (4, 4);
                clockTicksPerPulse = 0x18;
                nbrOf32ndNotePerBeat = 8;
            }
            if (tempoSigs.count > 0) {

                let data: [UInt32] = tempoSigs[0].data!;

                quarterNotePerMinute = data[0];
            }
            else {
                quarterNotePerMinute = 120;
            }
        }

        func printConfiguration() {

            println("\n/////////// TRACK #\(trackNbr) DATA /////////////");
            println("Track length = \(trackLength)");
            println("Signature = \(signature)");
            println("Number of clock ticks per beat = \(clockTicksPerPulse)");
            println("Number of 32nd notes between each beat = \(nbrOf32ndNotePerBeat)");
            println("BPM = \(quarterNotePerMinute)");
            println();
            println("Channel = \(channel)");
            println("Instrument ID = \(instrumentID)");
            println("////////////////////////////////////\n");
        }

        func getNoteArray() -> [UInt32 : [GenericMidiEvent<ByteBuffer>]] {

            var notes: [UInt32 : [GenericMidiEvent<ByteBuffer>]] = [0 : []];
            var currentDt: UInt32 = 0;

            for midiEvent in midiEvents {

                if let tmEvent = midiEvent as? TimedEvent<ByteBuffer> {

                    if (tmEvent.deltaTime > 0) {

                        currentDt += tmEvent.deltaTime;
                        notes[currentDt] = [];
                    }
                    notes[currentDt]!.append(tmEvent);
                }
            }
            let keys = notes.keys.array.sorted { $0 < $1 } ;
            for dt in keys {
                println("key = \(dt)\nValue = \(notes[dt]!)");
            }
            return notes;
        }
    }

    var dataBuffer: ByteBuffer;
    var tracks: [Track] = [];

    var headerMark: String              = "";
    var headerLength: UInt32            = 0;
    var midiFileType: UInt16            = 0;
    var nbrOfTracks: UInt16             = 0;
    var deltaTickPerQuarterNote: UInt16 = 0;

    var smallestTimeDiv: UInt32         = NoteValue.breve.rawValue;

    public init(data: NSData) {

        self.dataBuffer = ByteBuffer(order: LittleEndian(), capacity: data.length + 1);
        data.getBytes(self.dataBuffer.data, length: data.length);

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

    func parseTracks() {

        build_allTracks:
        for (var idx: UInt16 = 0; idx < nbrOfTracks; idx++) {

            var track: Track = Track(trackData: dataBuffer, trackNbr: idx + 1);
            track.getNoteArray();

            find_smallestTimeDivision:
            for midiEvent in track.midiEvents {

                if let tmEvent = midiEvent as? TimedEvent<ByteBuffer> {

                    if (tmEvent.deltaTime > 0) {

                        smallestTimeDiv = (smallestTimeDiv > tmEvent.deltaTime) ? tmEvent.deltaTime : smallestTimeDiv;
                    }
                }
            }
        }
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

public func getNextEvent(buffer: ByteBuffer, inout isMetaEvent: Bool) -> UInt8 {

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

public func isMetaEventByte(currentByte: UInt8) -> Bool {

    return currentByte == 0xFF
}

public func processStatusByte(statusByte: UInt8) -> MidiEventType {

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
