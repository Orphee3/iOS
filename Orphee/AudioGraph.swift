//
//  AudioGraph.swift
//  Orphee
//
//  Created by John Bob on 29/01/15.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import AVFoundation

class AudioGraph {

    var sampleRate: Float64 = 44_100; // Default hardware sample rate in Hz
    var graph: AUGraph! = AUGraph();		// The actual processing Audio Graph
    lazy var ioUnit: AudioUnit! = AudioUnit();	// The default I/O unit
    lazy var sampler: AudioUnit! = AudioUnit();	// The default sampler unit

    func createAudioGraph() -> Bool {

        var ac: AudioComponentDescription;
        var sampler: AUNode = AUNode();
        var out: AUNode = AUNode();
        var result: OSStatus = noErr;

        result = NewAUGraph(&graph!);

        result = buildOutputNode(&out);
        result = buildSamplerNode(&sampler);

        /*
        ** Open the processing graph, then connect the sampler as the input source of the output node
        */
        result = AUGraphOpen(graph);
        result = AUGraphConnectNodeInput(graph, sampler, 0, out, 0);

        /*
        ** Get a reference to the sampler and output Units
        */
        result = AUGraphNodeInfo(graph, out, nil, &ioUnit!);
        result = AUGraphNodeInfo(graph, sampler, nil, &self.sampler!);

        return (result == noErr);
    }

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

    func startAudioGraph() -> Bool {

        var result: OSStatus = noErr;

        //TODO: Might need to change to early return on error.
        result = AUGraphInitialize(graph!);
        if (result != noErr) {
            println("got error \(result) on graph init");
        }
        result = AUGraphStart(graph!);
        if (result != noErr) {
            println("got error \(result) on graph start");
        }

        return (result == noErr);
    }

    func loadPresetFromPList(inout plist: CFPropertyListRef) -> OSStatus {

        var result: OSStatus = noErr;
        var szPlist: UInt32 = UInt32(sizeofValue(plist));

        result = AudioUnitSetProperty(
            sampler,
            AudioUnitPropertyID(kAudioUnitProperty_ClassInfo),
            AudioUnitScope(kAudioUnitScope_Global),
            0,
            &plist, szPlist
        );
        println("Got error #\(result)");
        return result;
    }

    /////////////////////////////
    //// Audio Output methods ///
    /////////////////////////////

    func playNote(note: UInt32) -> OSStatus {

        var result: OSStatus = noErr;
        var cmd: UInt32 = 0x9 << 4 | 0;

        result = MusicDeviceMIDIEvent(sampler, cmd, note, 127, 0);
        return result;
    }


    func stopNote(note: UInt32) -> OSStatus {

        var result: OSStatus = noErr;
        var cmd: UInt32 = 0x8 << 4 | 0;

        result = MusicDeviceMIDIEvent(sampler, cmd, note, 0, 0);
        return result;
    }

    /////////////////////////////
    ////// Utility methods //////
    /////////////////////////////

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

    func buildSamplerNode(inout sampler: AUNode) -> OSStatus {

        /*
        ** add the sampler node to the processing graph
        */
        var ac: AudioComponentDescription = mkComponentDescription(
            type: OSType(kAudioUnitType_MusicDevice),
            subType: OSType(kAudioUnitSubType_Sampler)
        );
        return AUGraphAddNode(graph, &ac, &sampler);
    }

    func buildOutputNode(inout out: AUNode) -> OSStatus {

        /*
        ** add the output node to the processing graph
        */
        var ac: AudioComponentDescription = mkComponentDescription(
            type: OSType(kAudioUnitType_Output),
            subType: OSType(kAudioUnitSubType_RemoteIO)
        );
        return AUGraphAddNode(graph, &ac, &out);
    }

    func mkComponentDescription(type: OSType = OSType(0), subType: OSType = OSType(0)) -> AudioComponentDescription {

        return AudioComponentDescription(
            componentType: type,
            componentSubType: subType,
            componentManufacturer: OSType(kAudioUnitManufacturer_Apple),
            componentFlags: 0,
            componentFlagsMask: 0
        );
    }

    init() {

    }

    deinit {
        AUGraphStop(graph);
        AUGraphUninitialize(graph);
        AUGraphClearConnections(graph);
        AUGraphClose(graph);
        DisposeAUGraph(graph);
        graph = nil;
    }

}
