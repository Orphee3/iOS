//
//  MIDIByteBufferCreator.swift
//  Orphee
//
//  Created by JohnBob on 14/03/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit
import AudioToolbox

let kMIDIFile_trackMark: String = "MTrk";
let kMIDIFile_trackMarkSize: Int = 4;
let kMIDIFile_fileHeaderMark: String = "MThd";
let kMIDIFile_fileHeaderMarkSize: Int = 4;

let kMIDIFile_headerLength: Int = 6;

let kMIDITrack_headerLength: Int = 23;

/// Hexadecimal representation of a `time signature` event:
///   - 0xFF = MIDI Meta event
///   - 0x58 = MIDI time signature event
///   - 0x04 = 4 Bytes of data follow
let kMIDIEvent_timeSignature: [UInt8] = [0x00, 0xFF, 0x58, 0x04];

/// Hexadecimal representation of a `set tempo` event:
///   - 0xFF = MIDI Meta event
///   - 0x51 = MIDI time signature event
///   - 0x03 = 4 Bytes of data follow
let kMIDIEvent_setTempo: [UInt8] = [0x00, 0xFF, 0x51, 0x03];

let kMIDIEvent_endOfTrack: [UInt8] = [0x00, 0xFF, 0x2F, 0x00];

/// Hexadecimal representation of the default `4/4` time signature:
/// 0x04 = time signature numerator is 4
/// 0x02 = time signature denominator is 2^2 = 4
/// 0x18 = metronome clicks once every 24 MIDI clock tick
/// 0x08 = number of 32th notes per beat (8 = 1/4 note per beat).
let kMIDIEventDefaultData_timeSig: [UInt8] = [0x04, 0x02, 0x18, 0x08];

/// Hexadecimal representation of the default `120 bpm` tempo:
/// 0x07A120 = 500_000: 60_000_000/500_000 = 120 quarter_notes/minute
let kMIDIEventDefaultData_setTempo: [UInt8] = [0x07, 0xA1, 0x20];


func get7LowestBits<T where T: UnsignedIntegerType>(input: T) -> UInt8 {
    return UInt8(input.toUIntMax() & 0x7F);
}

func getFullByte<T where T: UnsignedIntegerType>(input: T) -> UInt8 {
    return UInt8(input.toUIntMax() & 0xFF);
}

func prepareInputForVLV<T where T: UnsignedIntegerType>(input: T) -> [UInt8] {

    var out: [UInt8] = (input > 0 ? [] : [0]);
    var inp = input.toUIntMax();

    while (inp > 0) {

        out.append(get7LowestBits(inp));
        inp >>= 7;
    }
    return out;
}

func decomposeToBytes<T where T: UnsignedIntegerType>(input: T) -> [UInt8] {

    var out: [UInt8] = (input > 0 ? [] : [0]);
    var inp = input.toUIntMax();

    while (inp > 0) {

        out.append(getFullByte(inp));
        inp >>= 8;
    }
    return out;
}


let setHighestOrderBit = { (input: UInt8) -> UInt8 in
    return input | 0x80;
}

public class MIDIByteBufferCreator: pMIDIByteStreamBuilder {

    public struct sTrack {
        let ppqn: UInt32;
        var trackLength: Int = 0;
        var channel: UInt8      = 0;

        var header: ByteBuffer;
        var channelPrg: ByteBuffer;
        lazy var body: ByteBuffer! = nil;

        init(ppqn: UInt16, channel: UInt8, startTime: UInt32, instrument: Int) {

            self.ppqn    = UInt32(ppqn)
            header       = ByteBuffer(order: LittleEndian(), capacity: kMIDITrack_headerLength);
            channelPrg   = ByteBuffer(order: LittleEndian(), capacity: kMIDIEventMaxSize_deltaTime + kMIDIEventMaxSize_programChange);
            self.channel = channel;

            fillHeader();
            mkChannelPrg(channel, startTime: startTime, instrument: instrument);
        }

        mutating func fillHeader() {

            header.putUTF8(kMIDIFile_trackMark);
            header.mark();

            header.putUInt32(swapUInt32(UInt32(trackLength)));

            header.putUInt8(kMIDIEvent_timeSignature);
            header.putUInt8(kMIDIEventDefaultData_timeSig);

            header.putUInt8(kMIDIEvent_setTempo);
            header.putUInt8(kMIDIEventDefaultData_setTempo);

            trackLength = kMIDIFile_trackMarkSize + sizeofValue(trackLength)
                + kMIDIEvent_timeSignature.count + kMIDIEventDefaultData_timeSig.count
                + kMIDIEvent_setTempo.count + kMIDIEventDefaultData_setTempo.count
        }

        mutating func mkChannelPrg(channel: UInt8, startTime: UInt32, instrument: Int) {

            mkDeltaTime(channelPrg, deltaTime: startTime);
            channelPrg.putUInt8(eMidiEventType.programChange.rawValue + channel);
            channelPrg.putUInt8(UInt8(instrument));
            trackLength += kMIDIEventMaxSize_programChange;
        }

        mutating func mkDeltaTime(bbuf: ByteBuffer, deltaTime: UInt32) {

            var buffer: [UInt8] = prepareInputForVLV(deltaTime);
            for (var pos = buffer.count - 1; pos > 0; --pos) {
                bbuf.putUInt8(setHighestOrderBit(buffer[pos]));
            }
            bbuf.putUInt8(buffer[0]);
            trackLength += buffer.count;
        }

        mutating func noteEvent(event: eMidiEventType, note: UInt8, velocity: UInt8) {

            body.putUInt8(channel + event.rawValue);
            body.putUInt8(note);
            body.putUInt8(velocity);
            trackLength += kMIDIEventMaxSize_noteEvent;
        }

        mutating func buildTrack(events: [ [MIDINoteMessage] ]) {

            var silences: UInt32 = 0;
            var capacity: Int    = 0;

            for notes in events {
                capacity += (2 * notes.count * kMIDIEventMaxSize_noteEvent) + (2 * notes.count * kMIDIEventMaxSize_deltaTime) + kMIDIEvent_endOfTrack.count;
            }

            body = ByteBuffer(order: LittleEndian(), capacity: capacity);
            for notes in events {

                var deltaTime: UInt32 = 0;
                if (notes.count > 0) {
                    for (idx, note) in notes.enumerate() {
                        if (idx == 0) {
                            deltaTime = UInt32(eNoteLength.crotchet.rawValue * Float32(ppqn) * Float32(silences));
                            silences = 0
                        }
                        mkDeltaTime(body, deltaTime: deltaTime);
                        noteEvent(eMidiEventType.noteOn, note: note.note, velocity: note.velocity);
                        deltaTime = 0;
                    }
                    for (idx, note) in notes.enumerate() {
                        if (idx == 0) {
                            deltaTime = UInt32(note.duration * Float32(ppqn));
                        }
                        mkDeltaTime(body, deltaTime: deltaTime);
                        noteEvent(eMidiEventType.noteOff, note: note.note, velocity: 0);
                        deltaTime = 0;
                    }
                }
                else {
                    ++silences;
                }
            }
            body.putUInt8(kMIDIEvent_endOfTrack);
            trackLength += kMIDIEvent_endOfTrack.count;

            let pos = header.position;
            header.reset();
            header.putUInt32(swapUInt32(UInt32(trackLength)));
            header.position = pos;
        }

        mutating func unifiedBufferForTrack() -> ByteBuffer {

            let buffer = ByteBuffer(order: LittleEndian(), capacity: Int(trackLength));

            memcpy(UnsafeMutablePointer<Void>(buffer.data),
                UnsafeMutablePointer<Void>(header.data),
                header.position
            );
            buffer.position += header.position;
            memcpy(UnsafeMutablePointer<Void>(buffer.data + buffer.position),
                UnsafeMutablePointer<Void>(channelPrg.data),
                channelPrg.position
            );
            buffer.position += channelPrg.position;
            memcpy(UnsafeMutablePointer<Void>(buffer.data + buffer.position),
                UnsafeMutablePointer<Void>(body.data),
                body.position
            );
            buffer.position += body.position;
            return buffer;
        }
    }

    public let _timeResolution: UInt16;
    public let _trackCount: UInt16;

    let _fileHeaderLength: Int;

    var MidiFileType: UInt16  = 0;

    var _midiFile: String     = "";

    var fileHeader: ByteBuffer!;
    var tracks: [sTrack] = [];

    public required init(trkNbr: UInt16, ppqn: UInt16) {

        _fileHeaderLength = kMIDIFile_headerLength;
        _timeResolution   = ppqn;
        _trackCount       = trkNbr;
    }

    public func buildMIDIBuffer() {

        fileHeader = ByteBuffer(order: LittleEndian(), capacity: 15);
        fillHeader();
    }

    // TODO: set instrument dynamically.
    public func addTrack(notes: [[MIDINoteMessage]]) {

        var track = sTrack(ppqn: _timeResolution, channel: 0, startTime: 0, instrument: 0x2e);

        if (notes.count > 0) {
            track.buildTrack(notes);
            tracks.append(track);
        }
        else {
            print(kOrpheeDebug_bufferCreator_noEventsInTrack);
        }
    }

    public func toData() -> NSData {

        var size = fileHeader.position;
        let buffers = mkBuffersForTracks();

        for buffer in buffers {
            size += buffer.position;
        }

        print(kOrpheeDebug_bufferCreator_printInputDataSize(size));
        let fileBuf = ByteBuffer(order: LittleEndian(), capacity: size);

        memcpy(UnsafeMutablePointer<Void>(fileBuf.data + fileBuf.position),
            UnsafeMutablePointer<Void>(fileHeader.data),
            fileHeader.position
        );
        fileBuf.position += fileHeader.position;
        for buffer in buffers {
            memcpy(UnsafeMutablePointer<Void>(fileBuf.data + fileBuf.position),
                UnsafeMutablePointer<Void>(buffer.data),
                buffer.position
            );
            fileBuf.position += buffer.position;
        }

        print(kOrpheeDebug_bufferCreator_printBufferSize(fileBuf.position));
        return NSData(bytes: fileBuf.data, length: fileBuf.position);
    }

    func fillHeader() {
        // file header mark
        fileHeader.putUTF8(kMIDIFile_fileHeaderMark);

        // track header length
        fileHeader.putUInt32(swapUInt32(UInt32(_fileHeaderLength)));
        fileHeader.putUInt16(swapUInt16(MidiFileType));
        fileHeader.putUInt16(swapUInt16(_trackCount));
        fileHeader.putUInt16(swapUInt16(_timeResolution));
    }

    func mkBuffersForTracks() -> [ByteBuffer] {

        var buffers: [ByteBuffer] = [];

        for (var idx = 0; idx < tracks.count; idx++) {

            buffers.append(tracks[idx].unifiedBufferForTrack());
        }
        return buffers;
    }
}
