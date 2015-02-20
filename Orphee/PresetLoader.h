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

- (OSStatus) loadSynthFromPresetURL:(NSURL *)presetURL toAudioUnit:(AudioUnit *)aUnit;

- (OSStatus)loadFromDLSOrSoundFont:(CFURLRef)bankURL withPatch:(int)presetNumber toAudioGraph:(AudioUnit *)aUnit;

@end

#endif
