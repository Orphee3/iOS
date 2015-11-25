//
//  MIDIByteBufferCreator.swift
//  Orphee
//
//  Created by JohnBob on 14/03/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit
import AudioToolbox

///  Provides the 7 lowest order bits of given Unsigned integer.
///
///  - parameter input: Any unsigned integer.
///
///  - returns: A Byte containing the 7 lowest order bits of the input.
func get7LowestBits<T where T: UnsignedIntegerType>(input: T) -> UInt8 {
    return UInt8(input.toUIntMax() & 0x7F);
}

///  Provides the left-most Byte of given Unsigned integer.
///
///  - parameter input: Any unsigned integer
///
///  - returns: The left-most Byte of the input.
func getFullByte<T where T: UnsignedIntegerType>(input: T) -> UInt8 {
    return UInt8(input.toUIntMax() & 0xFF);
}

///  Decomposes the given unsigned integer into Bytes according to the Variable Length Value format.
///
///  - parameter input: Any unsigned integer.
///
///  - returns: An array of Bytes representing the input conforming to the Variable Length Value format.
func prepareInputForVLV<T where T: UnsignedIntegerType>(input: T) -> [UInt8] {

    var out: [UInt8] = (input > 0 ? [] : [0]);
    var inp = input.toUIntMax();

    while (inp > 0) {

        out.append(get7LowestBits(inp));
        inp >>= 7;
    }
    return out;
}

///  Decomposes the given unsigned integer into Bytes.
///
///  - parameter input: Any unsigned integer.
///
///  - returns: An array of Bytes composing the input.
func decomposeToBytes<T where T: UnsignedIntegerType>(input: T) -> [UInt8] {

    var out: [UInt8] = (input > 0 ? [] : [0]);
    var input = input.toUIntMax();

    while (input > 0) {
        out.append(getFullByte(input));
        input >>= 8
    }
    return out.reverse();
}

/// Closure setting the highest order bit on the given Byte.
let setHighestOrderBit = { (input: UInt8) -> UInt8 in
    return input | 0x80;
}

/// Checks if the highest order bit is set on the given Byte.
let isHighestOrderBitSet = { (input: UInt8) -> Bool in
    return (input & 0x80) == 0x80;
}

protocol pTrack {
    
    /// Length of the track.
    var trackLength: Int { get set}
    /// Buffer for the track's header.
    var header: ByteBuffer { get set}
    /// Buffer for all other events.
    var body: ByteBuffer! { get set }
    
    ///  Builds the header chunk buffer.
    mutating func fillHeader(data: [UInt8]);
    
    ///  Unify all the track's buffers.
    ///
    ///  - returns: A unified buffer containing all the track's information.
    mutating func unifiedBufferForTrack() -> ByteBuffer

    mutating func unifiedBufferForTrack(buffers: [ByteBuffer]) -> ByteBuffer
}

extension pTrack {
    
    mutating func fillHeader(data: [UInt8]) {
        header.putUTF8(kMIDIFile_trackMark);
        
        header.mark();
        header.putUInt32(swapUInt32(UInt32(trackLength)));
        
        header.putUInt8(data)
        trackLength = sizeof(UInt32) + data.count;
    }
    
    ///  Unify all the track's buffers.
    ///
    ///  - returns: A unified buffer containing all the track's information.
    mutating func unifiedBufferForTrack() -> ByteBuffer {
        return unifiedBufferForTrack([header, body])
    }

    mutating func unifiedBufferForTrack(buffers: [ByteBuffer]) -> ByteBuffer {

        updateTrackLength()
        let unifiedBuffer = ByteBuffer(order: LittleEndian(), capacity: Int(trackLength) + kMIDIFile_trackMarkSize + kMIDIEvent_endOfTrack.count);

        for buffer in buffers {
            memcpy(UnsafeMutablePointer<Void>(unifiedBuffer.data + unifiedBuffer.position),
                UnsafeMutablePointer<Void>(buffer.data),
                buffer.position
            );
            unifiedBuffer.position += buffer.position;
        }
        return unifiedBuffer;
    }

    private mutating func updateTrackLength() {
        let headerPos = header.position

        header.reset()
        header.putUInt32(swapUInt32(UInt32(trackLength)));
        header.position = headerPos
    }
}

/// Realisation of pMIDIByteStreamBuilder using a ByteBuffer.
public final class MIDIByteBufferCreator: pMIDIByteStreamBuilder {

    ///  Structure in charge of building tracks.
    struct sTrack: pTrack {

        /// Tempo
        let bpm: UInt;
        /// Time resolution
        let timeRes: UInt16;
        /// Length of the track.
        var trackLength: Int = 0;
        /// Channel to which the track's events belong.
        var channel: UInt8   = 0;

        /// Buffer for the track's header.
        var header: ByteBuffer;
        /// Buffer for the Program change.
        var channelPrg: ByteBuffer;
        /// Buffer for all other events.
        var body: ByteBuffer! = nil;

        ///  init
        ///
        ///  - parameter bpm:       The track's time resolution
        ///  - parameter channel:    The channel to which the track's events belong.
        ///  - parameter startTime:  The offset at which the track begins.
        ///  - parameter instrument: The instrument this track represents.
        ///
        ///  - returns: An initialized instance of sTrack.
        init(timeRes: UInt16, bpm: UInt, channel: UInt8, startTime: UInt32, instrument: UInt8) {

            self.bpm        = bpm;
            self.channel    = channel;
            self.timeRes    = timeRes;
            self.header     = ByteBuffer(order: LittleEndian(), capacity: kMIDIFile_trackMarkSize + sizeofValue(trackLength));
            self.channelPrg = ByteBuffer(order: LittleEndian(), capacity: kMIDIEventMaxSize_deltaTime + kMIDIEventMaxSize_programChange);

            fillHeader([]);
            mkChannelPrg(channel, startTime: startTime, instrument: instrument);
        }

        ///  Builds the program change buffer
        ///
        ///  - parameter channel:    The channel to which the track's events belong.
        ///  - parameter startTime:  The offset at which the track begins.
        ///  - parameter instrument: The instrument this track represents.
        mutating func mkChannelPrg(channel: UInt8, startTime: UInt32, instrument: UInt8) {

            mkDeltaTime(channelPrg, deltaTime: startTime);
            channelPrg.putUInt8(eMidiEventType.programChange.rawValue + channel);
            channelPrg.putUInt8(instrument);
            trackLength += kMIDIEventMaxSize_programChange;
        }

        ///  Build formatted delta-time.
        ///
        ///  - parameter bbuf:      Output buffer
        ///  - parameter deltaTime: Delta-time to format.
        mutating func mkDeltaTime(bbuf: ByteBuffer, deltaTime: UInt32) {

            var buffer: [UInt8] = prepareInputForVLV(deltaTime);
            for (var pos = buffer.count - 1; pos > 0; --pos) {
                bbuf.putUInt8(setHighestOrderBit(buffer[pos]));
            }
            bbuf.putUInt8(buffer[0]);
            trackLength += buffer.count;
        }

        ///  Build formatted note event.
        ///
        ///  - parameter event:    Event type to create.
        ///  - parameter note:     Note id.
        ///  - parameter velocity: Note velocity.
        mutating func noteEvent(event: eMidiEventType, note: UInt8, velocity: UInt8) {

            body.putUInt8(channel + event.rawValue);
            body.putUInt8(note);
            body.putUInt8(velocity);
            trackLength += kMIDIEventMaxSize_noteEvent;
        }

        ///  Build the track's main buffer from given events.
        ///
        ///  - parameter events: Events to add to the track's buffer.
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
                            deltaTime = UInt32(eNoteLength.crotchet.rawValue * Float32(timeRes) * Float32(silences));
                            silences = 0
                        }
                        mkDeltaTime(body, deltaTime: deltaTime);
                        noteEvent(eMidiEventType.noteOn, note: note.note, velocity: note.velocity);
                        deltaTime = 0;
                    }
                    for (idx, note) in notes.enumerate() {
                        if (idx == 0) {
                            deltaTime = UInt32(note.duration * Float32(timeRes));
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
        }

        mutating func unifiedBufferForTrack() -> ByteBuffer {
            return unifiedBufferForTrack([header, channelPrg, body])
        }
    }

    struct sTempoTrack: pTrack {

        /// Length of the track.
        var trackLength: Int = 0;
        /// Buffer for the track's header.
        var header: ByteBuffer;
        /// Buffer for all other events.
        var body: ByteBuffer! = nil;

        let tempoData: [UInt8]
        let timeSigData: [UInt8]
        init(timeSig: (UInt8, UInt8), bpm: UInt) {
            self.tempoData   = decomposeToBytes(60_000_000 / bpm);
            self.timeSigData = [timeSig.0, timeSig.1, 0x18, 0x08]
            self.header      = ByteBuffer(order: LittleEndian(), capacity: kMIDIFile_trackMarkSize + sizeofValue(trackLength));

            fillHeader([]);
            fillBody();
        }

        mutating func fillBody() {
            let timeSig = kMIDIEvent_timeSignature
            let tempo = kMIDIEvent_setTempo
            let EOT = kMIDIEvent_endOfTrack
            let bodySz = tempoData.count + timeSigData.count
                + timeSig.count + tempo.count

            trackLength += bodySz;

            body = ByteBuffer(order: LittleEndian(), capacity: bodySz + EOT.count);
            body.putUInt8(timeSig)
            body.putUInt8(timeSigData)
            body.putUInt8(tempo)
            body.putUInt8(tempoData)
            body.putUInt8(EOT)
        }
    }

    /// The file's time resolution.
    public let _timeResolution: UInt16;
    /// The file's track number.
    public var _trackCount: UInt16 {
        get {
            return UInt16(tracks.count)
        }
    }
    // The file's time signature
    public let _timeSignature: (UInt8, UInt8);
    // The file's tempo
    public let _tempo: UInt;

    /// The file's header chunk length.
    let _fileHeaderLength: Int;

    /// The MIDI file type used.
    var MidiFileType: UInt16  = 1;

    /// The file's name (?)
    var _midiFile: String     = "";

    /// The file's header chunk buffer.
    var fileHeader: ByteBuffer!;
    /// An array of all the built tracks.
    var tracks: [pTrack] = [];

    ///    Default initializer.
    ///
    ///    - parameter  trkNbr: The number of tracks the file will contain.
    ///    - parameter    ppqn: The time resolution, aka Pulse Per Quarter Note.
    ///    - parameter timeSig: The file's time signature.
    ///    - parameter     bpm: The file's tempo
    ///
    ///    - returns: Initializes the MIDIByteStreamBuilder.
    public init(trkNbr: UInt16, ppqn: UInt16 = kTimeResolution_AppleDefault, timeSig: (UInt8, UInt8) = (4, 4), bpm: UInt = 120) {

        _fileHeaderLength = kMIDIFile_headerLength
        _timeResolution   = kTimeResolution_AppleDefault
        _timeSignature    = (timeSig.0, UInt8(log10(Double(timeSig.1)) / log10(2)))
        _tempo            = bpm
    }

    ///  Builds the file's header chunk buffer.
    public func buildMIDIBuffer() {

        fileHeader = ByteBuffer(order: LittleEndian(), capacity: 15);
        fillHeader();
        tracks.append(sTempoTrack.init(timeSig: _timeSignature, bpm: _tempo));
    }

    // TODO: set instrument dynamically.
    ///  Builds track from the given event array.
    ///
    ///  - parameter notes: The notes to add to the track.
    ///  - parameter prog:  The MIDI program (instrument) associated with this track.
    public func addTrack(notes: [[MIDINoteMessage]], prog: MIDIChannelMessage) {

        var track = sTrack(timeRes: _timeResolution, bpm: _tempo, channel: UInt8(tracks.count - 1), startTime: 0, instrument: prog.data1);

        if (notes.count > 0) {
            track.buildTrack(notes);
            tracks.append(track);
        }
        else {
            print(kOrpheeDebug_bufferCreator_noEventsInTrack);
        }
    }

    ///  Transforms all the buffers into a unified NSData instance.
    ///
    ///  - returns: A unified NSData instance ready to be written to a file.
    public func toData() -> NSData {

        updateTrackCount()

        var size = 0;
        let buffers = [fileHeader] + mkBuffersForTracks();

        for buffer in buffers {
            size += buffer.position;
        }

        let fileBuf = ByteBuffer(order: LittleEndian(), capacity: size);
        var data = fileBuf.data + fileBuf.position;
        for buffer in buffers {
            data.assignFrom(buffer.data, count: buffer.position);
            data += buffer.position;
            fileBuf.position += buffer.position;
        }

        return NSData(bytes: fileBuf.data, length: fileBuf.position);
    }

    ///  Fills the file's header chunk buffer.
    func fillHeader() {
        // file header mark
        fileHeader.putUTF8(kMIDIFile_fileHeaderMark);

        // track header length
        fileHeader.putUInt32(swapUInt32(UInt32(_fileHeaderLength)));
        fileHeader.putUInt16(swapUInt16(MidiFileType));

        fileHeader.mark()
        fileHeader.putUInt16(swapUInt16(_trackCount));
        fileHeader.putUInt16(swapUInt16(_timeResolution));
    }

    ///  Builds an array of buffers for all tracks.
    ///
    ///  - returns: An array containing all the tracks unified buffers.
    func mkBuffersForTracks() -> [ByteBuffer] {

        var buffers: [ByteBuffer] = [];

        for (var idx = 0; idx < tracks.count; idx++) {

            buffers.append(tracks[idx].unifiedBufferForTrack());
        }
        return buffers;
    }
    
    func updateTrackCount() {
        let headerPos = fileHeader.position

        fileHeader.reset()
        fileHeader.putUInt16(swapUInt16(_trackCount));
        fileHeader.position = headerPos;
    }
}
