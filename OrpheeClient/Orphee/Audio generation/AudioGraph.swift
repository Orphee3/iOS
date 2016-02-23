//
//  AudioGraph.swift
//  Orphee
//
//  Created by John Bob on 29/01/15.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import AVFoundation

/// Groups all methods related to the creation, configuration and running of the audio graph.
class AudioGraph {

    /// Default hardware sample rate in Hz.
    var sampleRate: Float64 = 44_100;

    /// The actual processing Audio Graph
    var graph: AUGraph! = AUGraph();

    /// The default I/O unit
    lazy var ioUnit: AudioUnit! = AudioUnit();

    /// The default sampler unit
    lazy var sampler: AudioUnit! = AudioUnit();

    /// MARK: Construction and configuration
    //

    /// Builds the underlying AUGraph and its default AudioUnit.
    ///
    /// - returns: `false` if one of the underlying routines fail, `true` if all goes well.
    func createAudioGraph() -> Bool {

        var _: AudioComponentDescription;
        var sampler: AUNode = AUNode();
        var out: AUNode = AUNode();
        var result: OSStatus = noErr;

        result = NewAUGraph(&graph!);
        if (result != noErr) {
            return false;
        }

        result = buildOutputNode(&out);
        if (result != noErr) {
            return false;
        }
        result = buildSamplerNode(&sampler);
        if (result != noErr) {
            return false;
        }

        /*
        ** Open the processing graph, then connect the sampler as the input source of the output node
        */
        result = AUGraphOpen(graph);
        if (result != noErr) {
            return false;
        }
        result = AUGraphConnectNodeInput(graph, sampler, 0, out, 0);
        if (result != noErr) {
            return false;
        }

        /*
        ** Get a reference to the sampler and output Units
        */
        result = AUGraphNodeInfo(graph, out, nil, &ioUnit!);
        if (result != noErr) {
            return false;
        }
        result = AUGraphNodeInfo(graph, sampler, nil, &self.sampler!);

        return (result == noErr);
    }

    /// Initializes and sets different properties of the underlying AudioUnits
    ///
    /// - returns: `false` if one of the underlying routines fail, `true` if all goes well.
    func configureAudioGraph() -> Bool {

        var result: OSStatus = noErr;
        var FPS: UInt32 = 0;
        var fpsSize: UInt32 = UInt32(sizeofValue(FPS));

        result = AudioUnitInitialize(ioUnit);

        // set output Unit sample rate
        result = setAudioUnitsSampleRate();

        result = AudioUnitGetProperty(
            ioUnit!,
            AudioUnitPropertyID(kAudioUnitProperty_MaximumFramesPerSlice),
            AudioUnitScope(kAudioUnitScope_Global),
            0,
            &FPS, &fpsSize
        );

        result = AudioUnitSetProperty(
            sampler!,
            AudioUnitPropertyID(kAudioUnitProperty_MaximumFramesPerSlice),
            AudioUnitScope(kAudioUnitScope_Global),
            0,
            &FPS, fpsSize
        );

        return (result == noErr);
    }

    /// Initializes and starts the underlying AUGraph
    ///
    /// - returns: `false` if one of the underlying routines fail, `true` if all goes well.
    func startAudioGraph() -> Bool {

        var result: OSStatus = noErr;

        //TODO: Might need to change to early return on error.
        result = AUGraphInitialize(graph!);
        if (result != noErr) {
            print("got error \(result) on graph init", terminator: "");
        }
        result = AUGraphStart(graph!);
        if (result != noErr) {
            print("got error \(result) on graph start", terminator: "");
        }

        return (result == noErr);
    }

    /// MARK: Preset configuration
    //

    /// Applies the properties contained in `plist` to the sampler `AudioUnit`
    ///
    /// - parameter plist:   A valid property list as provided by `PresetMgr`
    ///
    /// - returns:  `noErr` if all goes well, another `OSStatus` error code if the underlying routine fail.
    func loadPresetFromPList(inout plist: CFPropertyListRef) -> OSStatus {

        var result: OSStatus = noErr;
        let szPlist: UInt32 = UInt32(sizeofValue(plist));

        result = AudioUnitSetProperty(
            sampler,
            AudioUnitPropertyID(kAudioUnitProperty_ClassInfo),
            AudioUnitScope(kAudioUnitScope_Global),
            0,
            &plist, szPlist
        );
        return result;
    }

    /// Applies the properties contained in `data` to the sampler `AudioUnit`
    ///
    /// - parameter data:    A valid `AUSamplerInstrumentData` structure as provided by `PresetMgr`
    ///
    /// - returns:  `noErr` if all goes well, another `OSStatus` error code if the underlying routine fail.
    func loadInstrumentFromInstrumentData(inout data: AUSamplerInstrumentData) -> OSStatus {

        var result: OSStatus = noErr;
        let szData: UInt32 = UInt32(sizeofValue(data));

        result = AudioUnitSetProperty(
            sampler,
            AudioUnitPropertyID(kAUSamplerProperty_LoadInstrument),
            AudioUnitScope(kAudioUnitScope_Global),
            0, &data, szData
        );
        return result;
    }

    /// MARK: Audio Output methods.
    //

    /// Sends a `NoteOn` MIDI event to the sampler `AudioUnit`
    ///
    /// - parameter note:    The note that is going to be played by the sampler.
    ///
    /// - returns:  `noErr` if all goes well, another `OSStatus` error code if the underlying routine fail.
    func playNote(note: UInt32) -> OSStatus {

        var result: OSStatus = noErr;
        let cmd: UInt32 = 0x9 << 4 | 0;

        result = MusicDeviceMIDIEvent(sampler, cmd, note, 127, 0);
        return result;
    }

    /// Sends a `NoteOff` MIDI event to the sampler `AudioUnit`
    ///
    /// - parameter note:    The note that the sampler needs to stop playing.
    ///
    /// - returns:  `noErr` if all goes well, another `OSStatus` error code if the underlying routine fail.
    func stopNote(note: UInt32) -> OSStatus {

        var result: OSStatus = noErr;
        let cmd: UInt32 = 0x8 << 4 | 0;

        result = MusicDeviceMIDIEvent(sampler, cmd, note, 0, 0);
        return result;
    }

    /// MARK: Utility methods
    //

    /// Sets the hardware sample rate for the *sampler* and *output* units. Default is 44100Hz.
    ///
    /// - returns:  `noErr` if all goes well, another `OSStatus` error code if the underlying routine fail.
    func setAudioUnitsSampleRate() -> OSStatus {

        var result: OSStatus = noErr;
        let sampleRateSize: UInt32 = UInt32(sizeofValue(sampleRate));

        result = AudioUnitSetProperty(
            ioUnit,
            AudioUnitPropertyID(kAudioUnitProperty_SampleRate),
            AudioUnitScope(kAudioUnitScope_Output),
            0,
            &sampleRate, sampleRateSize
        );

        result = AudioUnitSetProperty(
            sampler,
            AudioUnitPropertyID(kAudioUnitProperty_SampleRate),
            AudioUnitScope(kAudioUnitScope_Output),
            0,
            &sampleRate, sampleRateSize
        );

        return result;
    }

    /// Builds and adds a *sampler* `AUNode` to the graph.
    ///
    /// - parameter sampler:    A reference to the node to be built.
    ///
    /// - returns:  `noErr` if all goes well, another `OSStatus` error code if the underlying routine fail.
    func buildSamplerNode(inout sampler: AUNode) -> OSStatus {

        // add the sampler node to the processing graph
        //
        var ac: AudioComponentDescription = mkComponentDescription(
            OSType(kAudioUnitType_MusicDevice),
            subType: OSType(kAudioUnitSubType_Sampler)
        );
        return AUGraphAddNode(graph, &ac, &sampler);
    }

    /// Builds and adds an *output* `AUNode` to the graph.
    ///
    /// - parameter out:    A reference to the node to be built.
    ///
    /// - returns:  `noErr` if all goes well, another `OSStatus` error code if the underlying routine fail.
    func buildOutputNode(inout out: AUNode) -> OSStatus {


        // add the output node to the processing graph
        //
        var ac: AudioComponentDescription = mkComponentDescription(
            OSType(kAudioUnitType_Output),
            subType: OSType(kAudioUnitSubType_RemoteIO)
        );
        return AUGraphAddNode(graph, &ac, &out);
    }

    /// Builds an `AudioComponentDescription` with satisfying values.
    ///
    /// - parameter type:    The component type. Default is 0.
    /// - parameter subtype: The component's subtype. Default is 0.
    ///
    /// - returns: A valid `AudioComponentDescription` structure initialized with satisfying values.
    func mkComponentDescription(type: OSType = OSType(0), subType: OSType = OSType(0)) -> AudioComponentDescription {

        return AudioComponentDescription(
            componentType: type,
            componentSubType: subType,
            componentManufacturer: OSType(kAudioUnitManufacturer_Apple),
            componentFlags: 0,
            componentFlagsMask: 0
        );
    }

    /// MARK: init - deinit
    //

    /// First, stop and uninitialize the underlying `AUGraph`.
    /// Then clear all the connections between it's nodes.
    /// Finally close and dispose of it.
    deinit {
        AUGraphStop(graph);
        AUGraphUninitialize(graph);
        AUGraphClearConnections(graph);
        AUGraphClose(graph);
        DisposeAUGraph(graph);
        graph = nil;
    }
}
