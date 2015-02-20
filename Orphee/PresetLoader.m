//
//  PresetLoader.m
//  Orphee
//
//  Created by John Bob on 29/01/15.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PresetLoader.h"


@implementation PresetLoader

- (OSStatus)loadSynthFromPresetURL:(NSURL *)presetURL toAudioUnit:(AudioUnit *)aUnit {

    CFDataRef propertyResourceData = 0;
    Boolean   status;
    SInt32    errorCode            = 0;
    OSStatus  result               = noErr;

    // Read from the URL and convert into a CFData chunk
    status = CFURLCreateDataAndPropertiesFromResource(
            kCFAllocatorDefault,
            (__bridge CFURLRef) presetURL,
            &propertyResourceData,
            NULL,
            NULL,
            &errorCode
    );
    if (!status || errorCode != 0) {
        NSLog(@"\nError on Data/property loading: %d\n", (int) errorCode);
    }
    NSAssert (status == YES && propertyResourceData != 0,
              @"Unable to create data and properties from a preset. Error code: %d '%.4s'",
              (int) errorCode, (const char *) &errorCode);

    // Convert the data object into a property list
    CFPropertyListRef    presetPropertyList = 0;
    CFPropertyListFormat dataFormat = (CFPropertyListFormat) 0;
    CFErrorRef           errorRef           = NULL;
    presetPropertyList = CFPropertyListCreateWithData(
            kCFAllocatorDefault,
            propertyResourceData,
            kCFPropertyListImmutable,
            &dataFormat,
            &errorRef
    );

    // Set the class info property for the Sampler unit using the property list as the value.
    if (presetPropertyList != 0) {

        NSLog(@"PresetPropertyList == OK");
        result = AudioUnitSetProperty(
                *aUnit,
                kAudioUnitProperty_ClassInfo,
                kAudioUnitScope_Global,
                0,
                &presetPropertyList,
                sizeof(CFPropertyListRef)
        );
        if (result != noErr) {
            NSLog(@"\n\nERROR in %d\nData = { %p\n}\n\n", (int) result, presetPropertyList);
        }

        CFRelease(presetPropertyList);
    }
    if (errorRef) {
        CFRelease(errorRef);
    }

    CFRelease(propertyResourceData);

    return result;
}

- (OSStatus)loadFromDLSOrSoundFont:(CFURLRef)bankURL withPatch:(int)presetNumber toAudioGraph:(AudioUnit *)aUnit {

    OSStatus result = noErr;

    // fill out a bank preset data structure
    AUSamplerBankPresetData bpdata;
    bpdata.bankURL = (CFURLRef) bankURL;
    bpdata.bankMSB  = kAUSampler_DefaultMelodicBankMSB;
    bpdata.bankLSB  = kAUSampler_DefaultBankLSB;
    bpdata.presetID = (UInt8) presetNumber;

    // set the kAUSamplerProperty_LoadPresetFromBank property
    result = AudioUnitSetProperty(
            *aUnit,
            kAUSamplerProperty_LoadPresetFromBank,
            kAudioUnitScope_Global,
            0,
            &bpdata,
            sizeof(bpdata)
    );

    // check for errors
    NSCAssert (result == noErr,
               @"Unable to set the preset property on the Sampler. Error code:%d '%.4s'",
               (int) result,
               (const char *) &result);

    return result;
}

@end
