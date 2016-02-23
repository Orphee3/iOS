//
//  MIDIDataParser.swift
//  FileManagement
//
//  Created by Massil on 05/04/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit

///  Checks if given Byte is last Byte of a Variable Length Value.
///
///  - parameter byte: Byte to check.
///
///  - returns: `true` if it is, `false` otherwise.
func isLastVLVByte(byte: UInt8) -> Bool {

    return byte & 0x80 != 0;
}

/// Class MIDIDataParser
///
///
public class MIDIDataParser {

	///  Structure in charge of parsing tracks.
    public struct sTrack {

        /// Byte stream buffer containing the track's data.
        var dataBuffer: ByteBuffer;
        /// The number of the track.
        public var trackNbr: UInt16;
        /// The length of the track, in Bytes.
        var trackLength: UInt32 = 0;

        /// Number of MIDI clock ticks per metronome click (pulse).
        /// - remark: A 4/4 time signature sets this value to 24ticks/pulse. This is also the default.
        var clockTicksPerPulse: UInt32   = 0;
        /// Number of 1/32nd notes per MIDI quarter-note
        /// - remark: This defines what is considered a quarter-note. Defaults to 8.
        var nbrOf32ndNotePerBeat: UInt32 = 0;
        /// Channel to which the track's events belong.
        public var channel: UInt32              = 0;
        /// The instrument this track represents.
        public var instrumentID: Int            = 0;
        /// BPM or quarter-note per minute.
        var quarterNotePerMinute: UInt32 = 0;
        /// Time signature: numerator/denominator. Default 4/4.
        var signature: (UInt32, UInt32)  = (0, 0);

        /// Last event type.
        var currentEventType: eMidiEventType = eMidiEventType.unknown;
        /// Array containing all the parsed events.
        var midiEvents: [pMidiEvent] = [];

        ///  init
        ///
        ///  - parameter trackData: The buffer containing the track's data.
        ///  - parameter trackNbr:  The track number.
        ///
        ///  - returns: An initialized sTrack instance.
        init(trackData: ByteBuffer, trackNbr: UInt16) {

            self.dataBuffer = trackData;
            self.trackNbr = trackNbr;
            self.readHeader();

            self.readEvents();
            self.processReadData();
        }

        ///  Parses the track header information.
        mutating func readHeader() {

            // file header mark
            print(dataBuffer.getUTF8(4));

            // track header length
            trackLength = swapUInt32(dataBuffer.getUInt32());
        }

        ///  Parses all the track's events following the track header.
        mutating func readEvents() {

            var lastValidEventType = currentEventType;
            var lastValidEventChannel: UInt8 = 0;
            while (dataBuffer.hasRemaining
                && currentEventType != eMidiEventType.endOfTrack) {

                    let deltaTime = readTimeStamp();
                    let event: BasicMidiEvent<ByteBuffer>!;
                    let nextByte = try! peakNextByte(dataBuffer);
                    if (processStatusByte(nextByte) == eMidiEventType.runningStatus) {
                        event = makeMidiEvent(lastValidEventType, chan: lastValidEventChannel, delta: deltaTime);
                    }
                    else {
                        var meta = isSysResetByte(nextByte);
                        let statusByte = try! getNextStatusByte(dataBuffer, isMeta: &meta)

                        currentEventType = processStatusByte(statusByte, isMeta: meta);
                        event = makeMidiEvent(currentEventType, delta: deltaTime, chan: try? getChanForEventType(currentEventType, fromByte: statusByte));
                    }
                    try! event.readData(dataBuffer);
                    if (eMidiEventType.kMIDIEvents.contains(currentEventType)) {
                        lastValidEventChannel = UInt8(event.data![0]);
                        lastValidEventType = currentEventType;
                    }
                    midiEvents.append(event);
            }
        }

        ///  Parses current delta-time
        ///
        ///  - returns: Delta-time as an Int.
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

        ///  Fills sTrack instance properties with parsed data.
        mutating func processReadData() {

            var timeSigEvents = midiEvents.filter { $0.type == eMidiEventType.timeSignature };
            var tempoSigs = midiEvents.filter { $0.type == eMidiEventType.setTempo };
            var progChg = midiEvents.filter { $0.type == eMidiEventType.programChange };

            if (timeSigEvents.count > 0) {
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
                let data: [UInt32] = tempoSigs[0].data!;

                quarterNotePerMinute = data[0];
            }
            else {
                quarterNotePerMinute = 120;
            }
            instrumentID = progChg.count > 0 ? Int(progChg[0].data[1]) : 1;
        }

        ///  Pretty print of the track's properties.
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

        ///  Provides a dictionnary of all timed events with delta-time offsets as keys.
        ///
        ///  - returns: All timed events sorted by delta-time offset.
        func getNoteArray() -> [UInt32 : [pMidiEvent]] {

            var timedEvents: [UInt32 : [pMidiEvent]] = [0 : []];
            var currentDt: UInt32 = 0;

            for midiEvent in midiEvents {
                if let tmEvent = midiEvent as? pTimedMidiEvent {

                    if (tmEvent.deltaTime > 0) {
                        currentDt += tmEvent.deltaTime;
                        timedEvents[currentDt] = [];
                    }
                    timedEvents[currentDt]!.append(tmEvent);
                }
            }
            return timedEvents;
        }
    }

    /// Byte stream buffer containing the MIDI file's data.
    var dataBuffer: ByteBuffer;
    /// An array containing all parsed tracks.
    public var tracks: [sTrack] = [];

    /// File header mark.
    var headerMark: String              = "";
    /// File header length.
    var headerLength: UInt32            = 0;
    /// MIDI file type. (0, 1 or 2)
    var midiFileType: UInt16            = 0;
    /// Number of tracks in the file.
    var nbrOfTracks: UInt16             = 0;
    /// Time resolution.
    var deltaTickPerQuarterNote: UInt16 = 0;

    /// Smallest time division in the file (= smallest delta-time).
    var smallestTimeDiv: UInt32         = 0;

    private var tempo: UInt             = 120;

    public var Tempo: UInt {
        get {
            return tempo
        }
    }
    ///  init
    ///
    ///  - parameter data: The MIDI file's raw data.
    ///
    ///  - returns: An initialized instance of MIDIDataParser.
    public init(data: NSData) {

        self.dataBuffer = ByteBuffer(order: LittleEndian(), capacity: data.length + 1);
        data.getBytes(self.dataBuffer.data, length: data.length);

        self.readHeader();
        self.smallestTimeDiv = UInt32(eNoteLength.breve.rawValue) * UInt32(self.deltaTickPerQuarterNote); // Set to longest supported note;
    }

    ///  Parses the file's header chunk.
    func readHeader() {

        // file header mark
        headerMark = dataBuffer.getUTF8(4);

        // track header length
        headerLength = swapUInt32(dataBuffer.getUInt32());
        midiFileType = swapUInt16(dataBuffer.getUInt16());
        nbrOfTracks = swapUInt16(dataBuffer.getUInt16());
        deltaTickPerQuarterNote = swapUInt16(dataBuffer.getUInt16());
    }

    ///  Parses each track in the file and provides all timed events for each track.
    ///
    ///  - returns: A dictionnary with the track number as key and an array of all timed events for the track as value.
    public func parseTracks() -> [Int : [[Int]]] {

        var tracks: [Int : [[Int]]] = [:];

        build_allTracks:
            for idx in 0..<self.nbrOfTracks {
                let track: sTrack = sTrack(trackData: dataBuffer, trackNbr: idx);
                track.getNoteArray();
                if (track.quarterNotePerMinute > 0) {
                    tempo = UInt(track.quarterNotePerMinute)
                }
                self.tracks.append(track);

                let timedEvents: [pTimedMidiEvent] = track.midiEvents.flatMap({ $0 as? pTimedMidiEvent });

                for tmEvent in timedEvents where tmEvent.deltaTime > 0 {
                    smallestTimeDiv = (smallestTimeDiv > tmEvent.deltaTime) ? tmEvent.deltaTime : smallestTimeDiv;
                }
                var i: Int = 0;
                var cleanedEvents: [[Int]] = [];
                for event in timedEvents {
                    if (event.deltaTime >= self.smallestTimeDiv && event.deltaTime > 0) {
                        let silences = Int(event.deltaTime / self.smallestTimeDiv);
                        cleanedEvents.appendContentsOf([[Int]](count: silences, repeatedValue: []));
                        i += silences;
                    }
                    if (event.type == eMidiEventType.noteOn) {
                        if (cleanedEvents.count <= i) {
                            cleanedEvents.append([])
                        }
                        cleanedEvents[i].append(Int(event.data![1]));
                    }
                }
                tracks[Int(idx)] = cleanedEvents;
        }
        return tracks;
    }

    ///  pretty print the file's properties.
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

///  Prints the buffer Byte per Byte.
///
///  - parameter dataBuffer:  The buffer to print.
///  - parameter trackLength: The number of Bytes to print.
func printData(dataBuffer: ByteBuffer, trackLength: UInt32) {

    dataBuffer.mark();
    print("");
    for (var i: UInt32 = 0, len: UInt32 = trackLength; i <= len; ++i) {
        if (i < trackLength && i % 8 < 7) {
            let byte = dataBuffer.getUInt8();
            let strByte: String!;
//            if (byte < 128 && byte != 0) {
//                strByte = "  " + String(byte);
//            }
//            else {
                strByte = (byte > 15 ? "0x" : "0x0") + String(byte, radix: 16);
//            }
            print(strByte!, terminator: "\t");
        }
        else {
            print("");
        }
    }
    dataBuffer.reset();
}
