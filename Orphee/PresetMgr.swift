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

    var presetLoader: PresetLoader = PresetLoader();

    func loadPresetFromURL(url: NSURL, graphMgr: AudioGraph) -> Bool {

        var res = presetLoader.loadSynthFromPresetURL(url, toAudioUnit: &(graphMgr.sampler!));
        println("\n\nFOR \(url)\nERROR \(res)\n");
        return (noErr == res);
    }

    func loadSoundBankFromURL(url: NSURL, patchId: Int32, graphMgr: AudioGraph) -> Bool {

        var res = presetLoader.loadFromDLSOrSoundFont(url, withPatch: patchId, toAudioGraph: &(graphMgr.sampler!));
        println("\n\nFOR \(url)\nERROR \(res)\n");
        return (noErr == res);
    }

/**
    Retrieves raw data from the file at the given path.
    Always check if error is non-nil as data is not guaranteed to be nil if an error occured.

    :returns:	A pair of optionals
    :returns:	If the file exists and is reachable, data is a reference to the file's raw data.
    			If an error occured error is set.
*/
    func getDataFromRessourceWithPath(path: String) -> (data: CFDataRef?, error: NSError?) {

        var err: NSError? = nil;
        let data: CFDataRef? = NSData(contentsOfFile: path, options: NSDataReadingOptions.DataReadingUncached, error: &err);
        return (data, err);
    }

/**
    Retrieves a property list (PList) from the raw data provided.
    Always check if error in non-nil as plist is not guaranteed to be nil if an error occured.
    
    :returns:	A pair of optionals
    :returns:	Provided data is the well-formatted raw data of a valid file, plist is a reference to the file's property list.
    			If an error occured error is set.
*/
    func getPListFromRawData(data: CFData) -> (plist: CFPropertyListRef?, error: NSError?) {

        var format: CFPropertyListFormat = CFPropertyListFormat.OpenStepFormat;
        var err: Unmanaged<CFError>? = nil;
        var errRet: NSError? = nil;

        var plist: CFPropertyList? = CFPropertyListCreateWithData(kCFAllocatorDefault, data, CFPropertyListMutabilityOptions.Immutable.rawValue, &format, &err).takeRetainedValue();

        if let ERR = err?.takeUnretainedValue() {

            errRet = NSError(domain: CFErrorGetDomain(ERR), code: CFErrorGetCode(ERR), userInfo: nil);
            err?.release();
        }
        return (plist, errRet);
    }

/**
    Convenience wrapper around getDataFromRessourceWithPath and getPlistFromRawData.
    Always check if error in non-nil as plist is not guaranteed to be nil if an error occured.

    :returns:	A pair of optionals
    :returns:	If path is valid file and provided no error occurs, plist is a reference to the file's property list.
			    If an error occured error is set.
*/
    func getPlistFromRessourceWithPath(path: String) -> (plist: CFPropertyListRef?, error: NSError?) {

        var res = getDataFromRessourceWithPath(path);
        if let data = res.data {
            return getPListFromRawData(data);
        }
        return (nil, res.error);
    }
}