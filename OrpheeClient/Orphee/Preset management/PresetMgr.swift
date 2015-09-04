//
//  PresetMgr.swift
//  Orphee
//
//  Created by John Bob on 29/01/15.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import CoreFoundation

/// This class is in charge of providing an easy way of loading and changing presets on the fly.
class PresetMgr {

    /// ObjC class PresetLoader instance
    var presetLoader: PresetLoader = PresetLoader();

    /// MARK: ObjC wrappers
    //

    /// Convenience wrapper around the PresetLoader's `loadSynthFromPresetURL:toAudioUnit:` ObjC method
    ///
    /// - parameter url:         A URL to the preset file.
    /// - parameter graphMgr:    The AudioGraph containing the sampler unit on which to load the preset.
    ///
    /// - returns:   - true:  if no error occured
    ///             - false: otherwise
    func loadPresetFromURL(url: NSURL, graphMgr: AudioGraph) -> Bool {

        let res = presetLoader.loadSynthFromPresetURL(url, toAudioUnit: &(graphMgr.sampler!));
        if (res != noErr) {
            print("\n\nFOR \(url)\nERROR \(res)\n");
        }
        return (noErr == res);
    }

    /// Convenience wrapper around the PresetLoader's `loadSynthFromDLSOrSoundFont:withPatch:toAudioUnit:` ObjC method
    ///
    /// - parameter url:         A URL to the sound bank file.
    /// - parameter patchID:     The id of a patch in the given file.
    /// - parameter graphMgr:    The AudioGraph containing the sampler unit on which to load the patch.
    ///
    /// - returns:   - `true` if no error occured
    ///             - `false` otherwise
    func loadSoundBankFromURL(url: NSURL, patchId: Int32, graphMgr: AudioGraph) -> Bool {

        let res = presetLoader.loadSynthFromDLSOrSoundFont(url, withPatch: patchId, toAudioUnit: &(graphMgr.sampler!));
        if (res != noErr) {
            print("\n\nFOR \(url)\nERROR \(res)\n");
        }
        return (noErr == res);
    }


    /// MARK: AUPreset specific methods
    //

    /// Retrieves raw data from the file at the given path.
    /// Always check if error is non-nil as data is not guaranteed to be nil if an error occured.
    ///
    /// - parameter path:    The path to the resource file.
    ///
    /// - returns:   A pair of optionals.
    /// - returns:       - If the file exists and is reachable, `data` is a reference to the file's raw data.
    ///                 - If an error occured `error` is set.
    func getDataFromRessourceWithPath(path: String) -> (data: CFDataRef?, error: NSError?) {

        var err: NSError? = nil;
        let data: CFDataRef?
        do {
            data = try NSData(contentsOfFile: path, options: NSDataReadingOptions.DataReadingUncached)
        } catch let error as NSError {
            err = error
            data = nil
        };
        return (data, err);
    }

    /// Retrieves a property list (PList) from the raw data provided.
    /// Always check if error in non-nil as plist is not guaranteed to be nil if an error occured.
    ///
    /// - parameter data:    Raw data extracted from a preset file.
    ///
    /// - returns:	A pair of optionals.
    /// - returns:       - Given `data` is the well-formatted raw data of a valid file, `plist` is a reference to the retrieved property list.
    ///                 - If an error occured `error` is set.
    func getPListFromRawData(data: CFData) -> (plist: CFPropertyListRef?, error: NSError?) {

        var format: CFPropertyListFormat = CFPropertyListFormat.BinaryFormat_v1_0;
        var err: Unmanaged<CFError>? = nil;
        var errRet: NSError? = nil;

        let plist: CFPropertyList? = CFPropertyListCreateWithData(kCFAllocatorDefault, data, CFPropertyListMutabilityOptions.Immutable.rawValue, &format, &err)?.takeRetainedValue();

        if let ERR = err?.takeUnretainedValue() {

            errRet = NSError(domain: String(CFErrorGetDomain(ERR)), code: Int(CFErrorGetCode(ERR)), userInfo: nil);
            err?.release();
        }
        return (plist, errRet);
    }

    /// Convenience wrapper around getDataFromRessourceWithPath and getPlistFromRawData.
    /// Always check if error in non-nil as plist is not guaranteed to be nil if an error occured.
    ///
    /// - parameter path:    The path to the resource file.
    ///
    /// - returns:	A pair of optionals.
    /// - returns:       - If `path` is valid file and provided no error occurs, `plist` is a reference to the file's property list.
    ///                 - If an error occured `error` is set.
    func getPListFromRessourceWithPath(path: String) -> (plist: CFPropertyListRef?, error: NSError?) {

        let res = getDataFromRessourceWithPath(path);
        if let data = res.data {
            return getPListFromRawData(data);
        }
        return (nil, res.error);
    }


    /// MARK: SoundBank specific methods
    //

    /// Builds an AUSamplerInstrumentData structure corresponding to the Sound Bank file at the provided path.
    /// This method is specific to melodic instruments; If you want to load a percussion soundbank see getPercussionInstrumentFromSoundBank.
    /// A basic check is done to assertain wether the file has the correct format. Beware this is based only on the file extension!
    ///
    /// - parameter id:          The patch's id in the given sound bank file
    /// - parameter path:        The path to the sound bank file.
    /// - parameter isSoundFont: Determines if the file should be treated as a SoundFont file (e.g. *.sf2) or not (e.g. *.dls)
    ///
    /// - returns:   - If `path` is valid: The corresponding structure
    ///             - Else: returns `nil`.
    func getMelodicInstrumentFromSoundBank(id: UInt8 = 0, path: String, isSoundFont: Bool = true) -> AUSamplerInstrumentData? {

        var instru: AUSamplerInstrumentData? = nil;
        let url: NSURL? = NSURL(fileURLWithPath: path);

        if (!self.isPathToSoundBankFile(path, isSoundFont: isSoundFont)) {
            print("Not a Soundfont file")
            return nil;
        }
        if let URL = url {
            let type: UInt8 = UInt8(isSoundFont ? kInstrumentType_SF2Preset : kInstrumentType_DLSPreset);

            instru = AUSamplerInstrumentData(
                fileURL: Unmanaged<CFURLRef>.passRetained(URL),
                instrumentType: type,
                bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                bankLSB: UInt8(kAUSampler_DefaultBankLSB), presetID: id
            );
        }
        return instru;
    }

    /// Builds an AUSamplerInstrumentData structure corresponding to the Sound Bank file at the provided path.
    /// This method is specific to percussion instruments; If you want to load a melodic soundbank see getMelodicInstrumentFromSoundBank.
    /// A basic check is done to assertain wether the file has the correct format. Beware this is based only on the file extension!
    ///
    /// - parameter id:          The patch's id in the given sound bank file
    /// - parameter path:        The path to the sound bank file.
    /// - parameter isSoundFont: Determines if the file should be treated as a SoundFont file (e.g. *.sf2) or not (e.g. *.dls)
    ///
    /// - returns:   - If `path` is valid: The corresponding structure
    ///             - Else: returns `nil`.
    func getPercussionInstrumentFromSoundBank(id: UInt8 = 0, path: String, isSoundFont: Bool = true) -> AUSamplerInstrumentData? {

        var instru: AUSamplerInstrumentData? = nil;
        let url: NSURL? = NSURL(fileURLWithPath: path);

        if (!self.isPathToSoundBankFile(path, isSoundFont: isSoundFont)) {
            return nil;
        }
        if let URL = url {
            let type: UInt8 = UInt8(isSoundFont ? kInstrumentType_SF2Preset : kInstrumentType_DLSPreset);

            instru = AUSamplerInstrumentData(
                fileURL: Unmanaged<CFURLRef>.passRetained(URL),
                instrumentType: type,
                bankMSB: UInt8(kAUSampler_DefaultPercussionBankMSB),
                bankLSB: UInt8(kAUSampler_DefaultBankLSB), presetID: id
            );
        }
        return instru;
    }

    /// Checks if `path` has the correct extension.
    ///
    /// - parameter path:        The path to the sound bank file.
    /// - parameter isSoundFont: Determines the correct extension to check for.
    ///
    /// - returns:   - `true` if the `path` has the extension it's supposed to have.
    ///             - `false`otherwise.
    private func isPathToSoundBankFile(path: String, isSoundFont: Bool) -> Bool {

        let typeExt: String = isSoundFont ? "sf2" : "dls";
        
        if (!path.lowercaseString.hasSuffix(typeExt.lowercaseString)) {
            return false;
        }
        return true;
    }
}
