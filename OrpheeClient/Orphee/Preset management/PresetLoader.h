//
//  PresetLoader.h
//  Orphee
//
//  Created by John Bob on 03/02/15.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

#ifndef Orphee_PresetLoader_h
#define Orphee_PresetLoader_h

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>


@interface PresetLoader : NSObject

/**
    Retrieves the data from the AUPreset file pointed to by the given URL.
    This data is then processed and used to setup the given AudioUnit.

    @param  presetURL       A URL pointing to an AUPreset file
    @param  aUnit           The AudioUnit on which to apply the file's settings

    @return noErr if the process ended without error, an error code otherwise
*/
- (OSStatus)loadSynthFromPresetURL:(NSURL *)presetURL toAudioUnit:(AudioUnit *)aUnit;

/**
    Retrieves the data from the Sound Bank file pointed to by the given URL.
    This data is then processed and used to setup the given AudioUnit.

    @param  bankURL         A URL pointing to an SF2 or DLS file.
    @param  presetNumber    Is used to select a specific Patch if the file contains multiple presets; If the file contains only one Preset, it should be set to 0.
    @param  aUnit           The AudioUnit on which to apply the file's settings

    @return noErr if the process ended without error, an error code otherwise
*/
- (OSStatus)loadSynthFromDLSOrSoundFont:(CFURLRef)bankURL withPatch:(int)presetNumber toAudioUnit:(AudioUnit *)aUnit;

@end


#endif
