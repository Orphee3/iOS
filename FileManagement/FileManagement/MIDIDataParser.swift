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

    public struct sTrack {

        var dataBuffer: ByteBuffer;
        var trackNbr: UInt16;
        var trackLength: UInt32       = 0;

        /// sTrack configuration
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
            trackLength = swapUInt32(dataBuffer.getUInt32());

            // track time signature (stored as UInt32)
            var meta = false;
            var nextEvent = processStatusByte(getNextEvent(dataBuffer, isMetaEvent: &meta));
            midiEvents.append(makeMidiEvent(0, eventType: nextEvent, buffer: dataBuffer));

            // track tempo (stored as UInt32)
            nextEvent = processStatusByte(getNextEvent(dataBuffer, isMetaEvent: &meta));
            midiEvents.append(makeMidiEvent(0, eventType: nextEvent, buffer: dataBuffer));
        }

        mutating func readInstrument() {

            var meta = false;
            let nextEvent = processStatusByte(getNextEvent(dataBuffer, isMetaEvent: &meta));
            midiEvents.append(makeMidiEvent(0, eventType: nextEvent, buffer: dataBuffer));
        }

        mutating func readNoteEvents() {

            var nextEvent = eMidiEventType.unknown;
            while (dataBuffer.hasRemaining && nextEvent != eMidiEventType.endOfTrack) {

                let deltaTime = readTimeStamp();
                var meta = false;
                nextEvent = processStatusByte(getNextEvent(dataBuffer, isMetaEvent: &meta));
                midiEvents.append(makeMidiEvent(UInt32(deltaTime), eventType: nextEvent, buffer: dataBuffer));
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

            var timeSigEvents = midiEvents.filter { $0.type == eMidiEventType.timeSignature };
            var tempoSigs = midiEvents.filter { $0.type == eMidiEventType.setTempo };

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

            print("\n/////////// TRACK #\(trackNbr) DATA /////////////");
            print("Track length = \(trackLength)");
            print("Signature = \(signature)");
            print("Number of clock ticks per beat = \(clockTicksPerPulse)");
            print("Number of 32nd notes between each beat = \(nbrOf32ndNotePerBeat)");
            print("BPM = \(quarterNotePerMinute)");
            print("");
            print("Channel = \(channel)");
            print("Instrument ID = \(instrumentID)");
            print("////////////////////////////////////\n");
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
            let keys = notes.keys.array.sort { $0 < $1 } ;
            for dt in keys {
                print("key = \(dt)\nValue = \(notes[dt]!)");
            }
            return notes;
        }
    }

    var dataBuffer: ByteBuffer;
    var tracks: [sTrack] = [];

    var headerMark: String              = "";
    var headerLength: UInt32            = 0;
    var midiFileType: UInt16            = 0;
    var nbrOfTracks: UInt16             = 0;
    var deltaTickPerQuarterNote: UInt16 = 0;

    var smallestTimeDiv: UInt32         = 0;

    public init(data: NSData) {

        self.dataBuffer = ByteBuffer(order: LittleEndian(), capacity: data.length + 1);
        data.getBytes(self.dataBuffer.data, length: data.length);

        self.readHeader();
        self.printHeader();
        self.smallestTimeDiv = UInt32(eNoteLength.breve.rawValue) * UInt32(self.deltaTickPerQuarterNote); // Set to longest supported note;
    }

    func readHeader() {

        // file header mark
        headerMark = dataBuffer.getUTF8(4);

        // track header length
        headerLength = swapUInt32(dataBuffer.getUInt32());
        midiFileType = swapUInt16(dataBuffer.getUInt16());
        nbrOfTracks = swapUInt16(dataBuffer.getUInt16());
        deltaTickPerQuarterNote = swapUInt16(dataBuffer.getUInt16());
    }

    func parseTracks() -> [Int : [[Int]]] {

        var tracks: [Int : [[Int]]] = [:];

        build_allTracks:
            for (var idx: UInt16 = 0; idx < nbrOfTracks; idx++) {

                let track: sTrack = sTrack(trackData: dataBuffer, trackNbr: idx + 1);
                track.getNoteArray();

                let timedEvents: [TimedEvent<ByteBuffer>] = track.midiEvents
                    .filter({ $0 is TimedEvent<ByteBuffer> })
                    .map({ $0 as! TimedEvent<ByteBuffer> });

                for tmEvent in timedEvents {

                    if (tmEvent.deltaTime > 0) {

                        smallestTimeDiv = (smallestTimeDiv > tmEvent.deltaTime) ? tmEvent.deltaTime : smallestTimeDiv;
                    }
                }
                var i = 0;
                var cleanedEvents: [[Int]] = [[]];
                for event in timedEvents {

                    if (event.deltaTime >= smallestTimeDiv) {

                        let silences = event.deltaTime / smallestTimeDiv;
                        for (var j: UInt32 = 0; j < silences; ++j) {

                            cleanedEvents.append([]);
                            ++i;
                        }
                    }
                    if (event.type == eMidiEventType.noteOn) {
                        cleanedEvents[i].append(Int(event.data![1]));
                    }
                }
                tracks[Int(idx)] = cleanedEvents;
        }
        return tracks;
    }
    
    private func printHeader() {
        
        print("\n//////////// FILE DATA /////////////");
        print("Header mark = \(headerMark)");
        print("Header length = \(headerLength)");
        print("midi file type = \(midiFileType)");
        print("number of tracks = \(nbrOfTracks)");
        print("dtTicks/quarter note = \(deltaTickPerQuarterNote)");
        print("////////////////////////////////////\n");
    }
}
