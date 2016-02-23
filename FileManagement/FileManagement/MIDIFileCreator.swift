//
//  MIDIFileCreator.swift
//  Orphee
//
//  Created by JohnBob on 14/03/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit

public class MIDIFileCreator {

    public struct sTrack {
        let ppqn: UInt32;
        var trackLength: UInt32 = 0;
        var channel: UInt8      = 0;

        var header: ByteBuffer;
        var channelPrg: ByteBuffer;
        lazy var body: ByteBuffer! = nil;

        init(ppqn: UInt16, channel: UInt8, startTime: UInt32, instrument: Int) {

            self.ppqn    = UInt32(ppqn)
            header       = ByteBuffer(order: LittleEndian(), capacity: 24);
            channelPrg   = ByteBuffer(order: LittleEndian(), capacity: 7);
            self.channel = channel;

            fillHeader();
            mkChannelPrg(channel, startTime: startTime, instrument: instrument);
        }

        mutating func fillHeader() {

            // track head mark
            header.putUTF8("MTrk");
            header.mark();

            // track header length
            header.putUInt32(swapUInt32(trackLength));

            // track time signature (4/4)
            //
            // 0xFF = MIDI Meta event
            // 0x58 = MIDI time signature event
            // 0x04 = 4 Bytes of data follow
            header.putUInt32(swapUInt32(0x00FF5804));

            // 0x04 = time signature numerator is 4
            // 0x02 = time signature denominator is 2^2 = 4
            // 0x18 = metronome clicks once every 24 MIDI clock tick
            // 0x08 = number of 32nd notes per beat (8 = 1/4 note per beat).
            header.putUInt32(swapUInt32(0x04021808));

            // track tempo (number of 1/4 note per minute)
            //
            // 0xFF = MIDI Meta event
            // 0x51 = MIDI set tempo event
            // 0x03 = 3 Bytes of data follow -> number of μs/quarter_note
            header.putUInt32(swapUInt32(0x00FF5103));

            // 0x07A120 = 500_000: 60_000_000/500_000 = 120 quarter_notes/minute
            header.putUInt8(0x07);
            header.putUInt8(0xA1);
            header.putUInt8(0x20);

            trackLength = 19;
        }

        mutating func mkChannelPrg(channel: UInt8, startTime: UInt32, instrument: Int) {

            mkDeltaTime(channelPrg, deltaTime: startTime);
            channelPrg.putUInt8(0xC0 + channel);
            channelPrg.putUInt8(UInt8(instrument));
            trackLength += 2;
        }

        mutating func mkDeltaTime(bbuf: ByteBuffer, var deltaTime: UInt32) {

            var buffer: [UInt8] = [0, 0, 0, 0];
            var pos: Int        = 0;

            repeat {
                buffer[pos++] = UInt8(deltaTime & UInt32(0x7F));
                deltaTime >>= 7;
                ++trackLength;
            } while (deltaTime > 0);

            while (pos > 0)
            {
                pos--;
                if (pos > 0) {
                    bbuf.putUInt8(buffer[pos] | 0x80);
                }
                else {
                    bbuf.putUInt8(buffer[pos]);
                }
            }
        }

        mutating func noteEvent(event: eMidiEventType, note: Int, velocity: UInt8) {

            body.putUInt8(channel + event.rawValue);
            body.putUInt8(UInt8(note));
            body.putUInt8(velocity);
            trackLength += 3;
        }

        mutating func buildTrack(events: [ [Int] ]) {

            var silences: UInt32 = 0;
            var eventNb: Int     = 0;

            for notes in events {
                eventNb += (2 * notes.count * 3) + (2 * notes.count * 4) + 1;
            }

            body = ByteBuffer(order: LittleEndian(), capacity: eventNb);
            for notes in events {

                var deltaTime: UInt32 = 0;
                if (notes.count > 0) {
                    for (idx, note) in notes.enumerate() {
                        if (idx == 0) {
                            deltaTime = UInt32(eNoteLength.crotchet.rawValue * Float32(ppqn) * Float32(silences));
                            silences = 0
                        }
                        mkDeltaTime(body, deltaTime: deltaTime);
                        noteEvent(eMidiEventType.noteOn, note: note, velocity: 76);
                        deltaTime = 0;
                    }
                    for (idx, note) in notes.enumerate() {
                        if (idx == 0) {
                            deltaTime = UInt32(eNoteLength.crotchet.rawValue * Float32(ppqn));
                        }
                        mkDeltaTime(body, deltaTime: deltaTime);
                        noteEvent(eMidiEventType.noteOff, note: note, velocity: 0);
                        deltaTime = 0;
                    }
                }
                else {
                    ++silences;
                }
            }
            body.putUInt32(swapUInt32(0x00FF2F00));

            let pos = header.position;
            header.reset();
            header.putUInt32(swapUInt32(trackLength));
            header.position = pos;
        }

        mutating func unifiedBufferForTrack() -> ByteBuffer {

            //            let size = header.position + channelPrg.position + body.position;
            let buffer = ByteBuffer(order: LittleEndian(), capacity: Int(trackLength + 50));

            memcpy(UnsafeMutablePointer<Void>(buffer.data + buffer.position),
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

    var NumberOfTrack: UInt16 = 1;
    var MidiFileType: UInt16  = 0;

    var _midiFile: String     = "";

    let _fileHeaderLength: UInt32;
    let _deltaTicksPerQuarterNote: UInt16;

    var fileHeader: ByteBuffer;
    var tracks: [sTrack] = [];

    public init() {
        _fileHeaderLength         = 6;
        _deltaTicksPerQuarterNote = 60;

        fileHeader = ByteBuffer(order: LittleEndian(), capacity: 15);
        fillHeader();
    }

    func fillHeader() {
        // file header mark
        fileHeader.putUTF8("MThd");

        // track header length
        fileHeader.putUInt32(swapUInt32(_fileHeaderLength));
        fileHeader.putUInt16(swapUInt16(MidiFileType));
        fileHeader.putUInt16(swapUInt16(NumberOfTrack));
        fileHeader.putUInt16(swapUInt16(_deltaTicksPerQuarterNote));
    }

    public func addTrack(notes: [[Int]]) {

        var track = sTrack(ppqn: _deltaTicksPerQuarterNote, channel: 0, startTime: 0, instrument: 0x2e);

        /// FIXME: Crash if only silences (i.e. notes.count > 0 and 0 note events).
        if (notes.count > 0) {
            track.buildTrack(notes);
            tracks.append(track);
        }
        else {
            print("No events in given track: Ignoring");
        }
    }

    func mkBuffersForTracks() -> [ByteBuffer] {

        var buffers: [ByteBuffer] = [];

        for (var idx = 0; idx < tracks.count; idx++) {

            buffers.append(tracks[idx].unifiedBufferForTrack());
        }
        return buffers;
    }

    public func dataForFile() -> NSData {

        var size = fileHeader.position;
        let buffers = mkBuffersForTracks();

        for buffer in buffers {
            size += buffer.position;
        }

        print("\ntotal data size \(size)\n")
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
        
        print("\ntotal data in file buffer \(fileBuf.position)\n")
        return NSData(bytes: fileBuf.data, length: fileBuf.position);
    }
}
