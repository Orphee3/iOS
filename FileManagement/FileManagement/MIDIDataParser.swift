//
//  MIDIDataParser.swift
//  FileManagement
//
//  Created by Massil on 05/04/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit


func isLastVLVByte(byte: UInt8) -> Bool {

    return byte & 0x80 != 0;
}

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

        var currentEventType: eMidiEventType = eMidiEventType.unknown;
        var midiEvents: [pMidiEvent] = [];

        init(trackData: ByteBuffer, trackNbr: UInt16) {

            self.dataBuffer = trackData;
            self.trackNbr = trackNbr;
            self.readHeader();

            printData(trackData, trackLength: self.trackLength);

            self.readEvents();
            self.processReadData();
            self.printConfiguration();
        }

        mutating func readHeader() {

            // file header mark
            print(dataBuffer.getUTF8(4));

            // track header length
            trackLength = swapUInt32(dataBuffer.getUInt32());
        }

        mutating func readEvents() {

            var nextEventType = currentEventType;
            var lastValidEventType = currentEventType;
            var lastValidEventChannel: UInt8 = 0;
            while (dataBuffer.hasRemaining
                && currentEventType != eMidiEventType.endOfTrack) {

                    let deltaTime = readTimeStamp();
                    let event: GenericMidiEvent<ByteBuffer>!;
                    let nextByte = try! peakNextByte(dataBuffer);
                    nextEventType = processStatusByte(nextByte);
                    if (nextEventType == eMidiEventType.runningStatus) {

                        event = makeMidiEvent(lastValidEventType, chan: lastValidEventChannel, delta: UInt32(deltaTime));
                    }
                    else {
                        var meta = isMetaEventByte(nextByte);
                        let statusByte = try! getNextStatusByte(dataBuffer, isMeta: &meta)

                        print("nextByte: \(nextByte)", "statusByte: \(statusByte)", "pos: \(dataBuffer.position)", separator: ", ", terminator: " ");
                        currentEventType = processStatusByte(statusByte, isMeta: meta);
                        print(currentEventType == .timeSignature ? "pos: \(dataBuffer.position), event: \(currentEventType)" : "");
                        event = makeMidiEvent(currentEventType, delta: UInt32(deltaTime), chan: try? getChanForEventType(currentEventType, fromByte: statusByte));
                    }
                    try! event.readData(dataBuffer);
                    if (eMidiEventType.MIDIEvents.contains(currentEventType)) {
                        lastValidEventChannel = UInt8(event.data![0]);
                        lastValidEventType = currentEventType;
                    }
                    midiEvents.append(event);
            }
        }

        func readTimeStamp() -> Int {

            var result: Int = 0;

            while (true) {

                let currentByte: UInt8 = dataBuffer.getUInt8();

                if (isLastVLVByte(currentByte)) {
                    result += Int(get7LowestBits(currentByte));
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
            var progChg = midiEvents.filter { $0.type == eMidiEventType.programChange };

            if (timeSigEvents.count > 0) {

                print(kOrpheeDebug_dataParser_printTimeSigs(timeSigEvents));
                let data: [UInt32] = timeSigEvents[0].data!;

                signature = (data[0], data[1]);
                clockTicksPerPulse = data[2];
                nbrOf32ndNotePerBeat = data[3];
            }
            else {
                signature = (UInt32(kMIDIEventDefaultData_timeSig[0]), UInt32(kMIDIEventDefaultData_timeSig[1] * 2));
                clockTicksPerPulse = UInt32(kMIDIEventDefaultData_timeSig[2]);
                nbrOf32ndNotePerBeat = UInt32(kMIDIEventDefaultData_timeSig[3]);
            }
            if (tempoSigs.count > 0) {

                print(kOrpheeDebug_dataParser_printSetTempo(tempoSigs));
                let data: [UInt32] = tempoSigs[0].data!;

                quarterNotePerMinute = data[0];
            }
            else {
                quarterNotePerMinute = 120;
            }
            instrumentID = progChg.count > 0 ? Int(progChg[0].data[1]) : 1;
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

        func getNoteArray() -> [UInt32 : [pMidiEvent]] {

            var timedEvents: [UInt32 : [pMidiEvent]] = [0 : []];
            var currentDt: UInt32 = 0;

            print(kOrpheeDebug_dataParser_printAllEvents(midiEvents));
            for midiEvent in midiEvents {

                if let tmEvent = midiEvent as? pTimedMidiEvent {

                    if (tmEvent.deltaTime > 0) {

                        currentDt += tmEvent.deltaTime;
                        timedEvents[currentDt] = [];
                    }
                    timedEvents[currentDt]!.append(tmEvent);
                }
            }
            print(kOrpheeDebug_dataParser_printSortedTimedEvents(timedEvents));
            return timedEvents;
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

                let timedEvents: [pTimedMidiEvent] = track.midiEvents
                    .filter({ $0 is pTimedMidiEvent })
                    .map({ $0 as! pTimedMidiEvent });

                for tmEvent in timedEvents where tmEvent.deltaTime > 0 {

                    smallestTimeDiv = (smallestTimeDiv > tmEvent.deltaTime) ? tmEvent.deltaTime : smallestTimeDiv;
                }
                var i: Int = 0;
                var cleanedEvents: [[Int]] = [[]];
                for event in timedEvents {

                    if (event.deltaTime >= smallestTimeDiv) {

                        let silences = event.deltaTime / smallestTimeDiv;
                        cleanedEvents.appendContentsOf([[Int]](count: Int(silences), repeatedValue: []))
                        i += Int(silences);
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

func printData(dataBuffer: ByteBuffer, trackLength: UInt32) {
    
    dataBuffer.mark();
    print("");
    for (var i: UInt32 = 0, len: UInt32 = trackLength; i <= len; ++i) {
        if (i < trackLength && i % 8 < 7) {
            let byte = dataBuffer.getUInt8();
            let strByte: String!;
            if (byte < 128 && byte != 0) {
                strByte = "  " + String(byte);
            }
            else {
                strByte = (byte > 15 ? "0x" : "0x0") + String(byte, radix: 16);
            }
            print(strByte! + "\t");
        }
        else {
            print("");
        }
    }
    dataBuffer.reset();
}
