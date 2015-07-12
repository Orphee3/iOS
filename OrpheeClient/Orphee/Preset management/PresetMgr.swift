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
    /// :param: url         A URL to the preset file.
    /// :param: graphMgr    The AudioGraph containing the sampler unit on which to load the preset.
    ///
    /// :returns:   - true:  if no error occured
    ///             - false: otherwise
    func loadPresetFromURL(url: NSURL, graphMgr: AudioGraph) -> Bool {

        var res = presetLoader.loadSynthFromPresetURL(url, toAudioUnit: &(graphMgr.sampler!));
        if (res != noErr) {
            println("\n\nFOR \(url)\nERROR \(res)\n");
        }
        return (noErr == res);
    }

    /// Convenience wrapper around the PresetLoader's `loadSynthFromDLSOrSoundFont:withPatch:toAudioUnit:` ObjC method
    ///
    /// :param: url         A URL to the sound bank file.
    /// :param: patchID     The id of a patch in the given file.
    /// :param: graphMgr    The AudioGraph containing the sampler unit on which to load the patch.
    ///
    /// :returns:   - `true` if no error occured
    ///             - `false` otherwise
    func loadSoundBankFromURL(url: NSURL, patchId: Int32, graphMgr: AudioGraph) -> Bool {

        var res = presetLoader.loadSynthFromDLSOrSoundFont(url, withPatch: patchId, toAudioUnit: &(graphMgr.sampler!));
        if (res != noErr) {
            println("\n\nFOR \(url)\nERROR \(res)\n");
        }
        return (noErr == res);
    }


    /// MARK: AUPreset specific methods
    //

    /// Retrieves raw data from the file at the given path.
    /// Always check if error is non-nil as data is not guaranteed to be nil if an error occured.
    ///
    /// :param: path    The path to the resource file.
    ///
    /// :returns:   A pair of optionals.
    /// :returns:       - If the file exists and is reachable, `data` is a reference to the file's raw data.
    ///                 - If an error occured `error` is set.
    func getDataFromRessourceWithPath(path: String) -> (data: CFDataRef?, error: NSError?) {

        var err: NSError? = nil;
        let data: CFDataRef? = NSData(contentsOfFile: path, options: NSDataReadingOptions.DataReadingUncached, error: &err);
        return (data, err);
    }

    /// Retrieves a property list (PList) from the raw data provided.
    /// Always check if error in non-nil as plist is not guaranteed to be nil if an error occured.
    ///
    /// :param: data    Raw data extracted from a preset file.
    ///
    /// :returns:	A pair of optionals.
    /// :returns:       - Given `data` is the well-formatted raw data of a valid file, `plist` is a reference to the retrieved property list.
    ///                 - If an error occured `error` is set.
    func getPListFromRawData(data: CFData) -> (plist: CFPropertyListRef?, error: NSError?) {

        var format: CFPropertyListFormat = CFPropertyListFormat.BinaryFormat_v1_0;
        var err: Unmanaged<CFError>? = nil;
        var errRet: NSError? = nil;

        var plist: CFPropertyList? = CFPropertyListCreateWithData(kCFAllocatorDefault, data, CFPropertyListMutabilityOptions.Immutable.rawValue, &format, &err)?.takeRetainedValue();

        if let ERR = err?.takeUnretainedValue() {

            errRet = NSError(domain: String(CFErrorGetDomain(ERR)), code: Int(CFErrorGetCode(ERR)), userInfo: nil);
            err?.release();
        }
        return (plist, errRet);
    }

    /// Convenience wrapper around getDataFromRessourceWithPath and getPlistFromRawData.
    /// Always check if error in non-nil as plist is not guaranteed to be nil if an error occured.
    ///
    /// :param: path    The path to the resource file.
    ///
    /// :returns:	A pair of optionals.
    /// :returns:       - If `path` is valid file and provided no error occurs, `plist` is a reference to the file's property list.
    ///                 - If an error occured `error` is set.
    func getPListFromRessourceWithPath(path: String) -> (plist: CFPropertyListRef?, error: NSError?) {

        var res = getDataFromRessourceWithPath(path);
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
    /// :param: id          The patch's id in the given sound bank file
    /// :param: path        The path to the sound bank file.
    /// :param: isSoundFont Determines if the file should be treated as a SoundFont file (e.g. *.sf2) or not (e.g. *.dls)
    ///
    /// :returns:   - If `path` is valid: The corresponding structure
    ///             - Else: returns `nil`.
    func getMelodicInstrumentFromSoundBank(id: UInt8 = 0, path: String, isSoundFont: Bool = true) -> AUSamplerInstrumentData? {

        var instru: AUSamplerInstrumentData? = nil;
        var url: NSURL? = NSURL(fileURLWithPath: path);

        if (!self.isPathToSoundBankFile(path, isSoundFont: isSoundFont)) {
            return nil;
        }
        if let URL = url {
            var type: UInt8 = UInt8(isSoundFont ? kInstrumentType_SF2Preset : kInstrumentType_DLSPreset);

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
    /// :param: id          The patch's id in the given sound bank file
    /// :param: path        The path to the sound bank file.
    /// :param: isSoundFont Determines if the file should be treated as a SoundFont file (e.g. *.sf2) or not (e.g. *.dls)
    ///
    /// :returns:   - If `path` is valid: The corresponding structure
    ///             - Else: returns `nil`.
    func getPercussionInstrumentFromSoundBank(id: UInt8 = 0, path: String, isSoundFont: Bool = true) -> AUSamplerInstrumentData? {

        var instru: AUSamplerInstrumentData? = nil;
        var url: NSURL? = NSURL(fileURLWithPath: path);

        if (!self.isPathToSoundBankFile(path, isSoundFont: isSoundFont)) {
            return nil;
        }
        if let URL = url {
            var type: UInt8 = UInt8(isSoundFont ? kInstrumentType_SF2Preset : kInstrumentType_DLSPreset);

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
    /// :param: path        The path to the sound bank file.
    /// :param: isSoundFont Determines the correct extension to check for.
    ///
    /// :returns:   - `true` if the `path` has the extension it's supposed to have.
    ///             - `false`otherwise.
    private func isPathToSoundBankFile(path: String, isSoundFont: Bool) -> Bool {

        let typeExt: String = isSoundFont ? "sf2" : "dls";

        if (typeExt.lowercaseString != path.pathExtension.lowercaseString) {
            return false;
        }
        return true;
    }
}
