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

    func loadPresetFromURL(url: NSURL, graphMgr: AudioGraph) -> Bool {

        var resData: CFDataRef = NSData();
        var result: OSStatus = noErr;

        resData = CFURLCreateData(kCFAllocatorDefault, url, kCFStringEncodingASCII, 0);

        var plist: CFPropertyListRef = NSDictionary();
        var format: CFPropertyListFormat = CFPropertyListFormat(rawValue: CFIndex(0))!;
//        var err = CFErrorCreate(kCFAllocatorDefault, kCFErrorDomainOSStatus, CFIndex(50), CFDictionaryCreate(kCFAllocatorDefault, <#keys: UnsafeMutablePointer<UnsafePointer<Void>>#>, <#values: UnsafeMutablePointer<UnsafePointer<Void>>#>, <#numValues: CFIndex#>, <#keyCallBacks: UnsafePointer<CFDictionaryKeyCallBacks>#>, <#valueCallBacks: UnsafePointer<CFDictionaryValueCallBacks>#>))
        //       plist = CFPropertyListCreateWithData(kCFAllocatorDefault, resData, 0, &format, Unmanaged<CFError>.fromOpaque(nil));
        return true;
    }
}