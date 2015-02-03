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

- (OSStatus) loadSynthFromPresetURL:(NSURL *)presetURL toAudioUnit:(AudioUnit *)aUnit {

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

    NSAssert (status == YES && propertyResourceData != 0,
              @"Unable to create data and properties from a preset. Error code: %d '%.4s'",
              (int) errorCode, (const char *) &errorCode);

        // Convert the data object into a property list
    CFPropertyListRef    presetPropertyList = 0;
    CFPropertyListFormat dataFormat         = 0;
    CFErrorRef           errorRef           = 0;
    presetPropertyList = CFPropertyListCreateWithData(
                                                      kCFAllocatorDefault,
                                                      propertyResourceData,
                                                      kCFPropertyListImmutable,
                                                      &dataFormat,
                                                      &errorRef
                                                      );
    
        // Set the class info property for the Sampler unit using the property list as the value.                                      
    if (presetPropertyList != 0) {
        
        result = AudioUnitSetProperty(
                                      *aUnit,
                                      kAudioUnitProperty_ClassInfo,
                                      kAudioUnitScope_Global,
                                      0,
                                      &presetPropertyList,
                                      sizeof(CFPropertyListRef)
                                      );
        
        CFRelease(presetPropertyList);
    }
    
    if (errorRef) {
        CFRelease(errorRef);
    }
    
    CFRelease(propertyResourceData);
        
    return result;
}

@end