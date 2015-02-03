//
//  PresetMgr.swift
//  Orphee
//
//  Created by John Bob on 29/01/15.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import CoreFoundation


class PresetMgr {

//    func loadPresetFromURL(url: NSURL, graphMgr: AudioGraph) -> Bool {
//
//        var presetLoader: PresetLoader = PresetLoader();
//
//        var res = presetLoader.loadSynthFromPresetURL(url, toAudioUnit: &(graphMgr.sampler!));
//        println("\n\nFOR \(url)\nERROR \(res)\n");
//        return (noErr == res);
//    }

    func getDataFromRessourceForURL(url: NSURL) -> CFDataRef? {

        return NSData(contentsOfURL: url);
    }

    func getPListFromRessourceForURL(url: NSURL) -> CFPropertyListRef? {

        var plist: CFPropertyListRef? = nil;
        var data: CFData? = NSData(contentsOfURL: url);
        var format: CFPropertyListFormat = CFPropertyListFormat.OpenStepFormat;
        var err: Unmanaged<CFError>? = nil;

        if let DATA = data {
            plist = CFPropertyListCreateWithData(kCFAllocatorDefault, DATA, CFPropertyListMutabilityOptions.Immutable.rawValue, &format, &err).takeRetainedValue();
        }
        else {
            assertionFailure("FATAL ERROR: OBTAINED NO DATA");
        }

        if (err != nil) {
            println("\n\nERROR while creating PLIST: \(err?.takeRetainedValue())\n");
            plist = nil;
        }
        return plist;
    }
}