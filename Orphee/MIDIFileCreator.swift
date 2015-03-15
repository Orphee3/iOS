//
//  MIDIFileCreator.swift
//  Orphee
//
//  Created by JohnBob on 14/03/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit

func SwapUInt32(i: UInt32) -> UInt32
{
    var half1: UInt32 = ((i & 0xFF000000) >> 24) | ((i & 0x00FF0000) >> 8);
    var half2: UInt32 = ((i & 0x0000FF00) << 8) | ((i & 0x000000FF) << 24);
    return  half1 | half2;
}

func SwapUInt16(i: UInt16) -> UInt16
{
    return ((i & 0xFF00) >> 8) | ((i & 0x00FF) << 8);
}

class MIDIFileCreator {

    func writeOutMIDIFile() {

    }

    var NumberOfTrack: Int = 0;
    var MidiFileType: Int = 0;
    var _trackLength: Int = 0;

    var _midiFile: String = "";

    let _fileHeaderLength: Int;
    let _deltaTicksPerQuarterNote: Int;

    init() {
        _fileHeaderLength = 6;
        _deltaTicksPerQuarterNote = 60;
        _trackLength = 0;
    }

//    func CreateMidiFile(fileName: String, noteList: [Int : [Int]], currentInstrument: Int)
//    {
//        var folder: StorageFolder = ApplicationData.Current.LocalFolder;
//        this._midiFile = await folder.CreateFileAsync(fileName + ".mid", CreationCollisionOption.ReplaceExisting);

//        let resources: String = NSBundle.mainBundle().resourcePath!;

//        using (_writer = new BinaryWriter(this._midiFile.OpenStreamForWriteAsync().Result))
//        {
//            WriteMidiFileHeader();
//            WriteChannelProgram(0, channel: 0, programIndex: currentInstrument);
//            WriteTrack(noteList);
//            WriteTrackHeaderLengthNewValue();
//            WriteEndOfTrack();
//        }
//    }
//
//    func WriteMidiFileHeader()
//    {
//        "MThd".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)?.writeToFile(, atomically: <#Bool#>);
//        _writer.Write(SwapUInt32(_fileHeaderLength));
//        _writer.Write(SwapUInt16(MidiFileType));
//        _writer.Write(SwapUInt16(this.NumberOfTrack));
//        _writer.Write(SwapUInt16(_deltaTicksPerQuarterNote));
//        WriteMidiTrackHeader(0);
//    }
//
//    func WriteMidiTrackHeader(trackLength: Int)
//    {
//        this._writer.Write(Encoding.UTF8.GetBytes("MTrk"));
//        this._writer.Write(SwapUInt32((uint)trackLength));
//        this._trackLength += 4;
//        WriteTimeSignature();
//        WriteTempo();
//    }
//
//    func WriteTimeSignature()
//    {
//        this._writer.Write(SwapUInt32(0x00FF5804));
//        this._writer.Write(SwapUInt32(0x04021808));
//        this._trackLength += 8;
//    }
//
//    func WriteTempo()
//    {
//        this._writer.Write(SwapUInt32(0x00FF5103));
//        this._writer.Write((Byte)0x07);
//        this._writer.Write((Byte)0xA1);
//        this._writer.Write((Byte)0x20);
//        this._trackLength += 7;
//    }
//
//    func WriteChannelProgram(deltaTime: Int, channel: Int, programIndex: Int)
//    {
//        WriteDeltaTime(deltaTime);
//        this._writer.Write((Byte)(0xC0 + channel));
//        this._writer.Write((Byte)programIndex);
//        this._trackLength += 2;
//    }
//
//    func WriteTrack(noteList: [Int : [Note]])
//    {
//        for (var lineNumber = 0; lineNumber < noteList.Count; lineNumber++)
//        {
//            var silenceNumber = 0;
//
//            while (lineNumber < (noteList.Count - 1) && noteList[lineNumber].Count == 0)
//            {
//                silenceNumber++;
//                lineNumber++;
//            }
//
//            if (noteList[lineNumber].Count > 0)
//            {
//                for (var i = 0; i < noteList[lineNumber].Count; i++) {
//                    WriteMidiNoteEvent(silenceNumber == 0 ? 0 : (i == 0 ? (48 * silenceNumber) : 0), 0x90, 0, noteList[lineNumber][i], 76);
//                }
//                for (var i = 0; i < noteList[lineNumber].Count; i++) {
//                    WriteMidiNoteEvent(i == 0 ? 48 : 0, 0x80, 0, noteList[lineNumber][i], 0);
//                }
//            }
//        }
//    }
//
//    func WriteMidiNoteEvent(deltaTime: Int, eventCode: Int, channel: Int, noteIndex: Int, noteVelocity: Int)
//    {
//        WriteDeltaTime(deltaTime);
//        this._writer.Write((byte)(eventCode + channel));
//        this._writer.Write((byte)noteIndex);
//        this._writer.Write((byte)noteVelocity);
//        this._trackLength += 3;
//    }
//
//    func WriteTrackHeaderLengthNewValue()
//    {
//        this._writer.Seek(-this._trackLength, SeekOrigin.End);
//        this._writer.Write(SwapUInt32((uint)this._trackLength));
//        this._writer.Seek(0, SeekOrigin.End);
//    }
//
//    func WriteEndOfTrack()
//    {
//        this._writer.Write(SwapUInt32(0x00FF2F00));
//    }
//
//    func WriteDeltaTime(deltaTime: int)
//    {
//        var pos = 0;
//        var buffer = new byte[4];
//
//        do
//        {
//            buffer[pos++] = (byte)(deltaTime & 0x7F);
//            deltaTime >>= 7;
//            this._trackLength++;
//        } while (deltaTime > 0);
//
//        while (pos > 0)
//        {
//            pos--;
//            if (pos > 0)
//            this._writer.Write((byte)(buffer[pos] | 0x80));
//            else
//            this._writer.Write(buffer[pos]);
//        }
//    }
}