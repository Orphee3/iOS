//
//  PathManager.swift
//  Orphee
//
//  Created by Massil on 15/03/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit

/// Class PathManager
///
/// Proxy for accessing an application special directories.
class PathManager {

    enum pMgrErr {
        case fileExists
        case noDir
        case nsError(NSError)
        case unknown(String)
    }

    class func createResourceFile(filename: String, inSubdirectory dir: String? = nil) -> (path: String?, err: pMgrErr?) {

        let resourcePath: String = NSBundle.mainBundle().resourcePath!;
        var path: String? = resourcePath;

        if let subdir = dir {
            let res = getCompletePathWith(basedir: resourcePath, subdir: subdir);

            path = res.path;
            if (path == nil) {
                let res2 = buildPathFrom(resourcePath, subdir: subdir);

                path = res2.path;
                if (path == nil) {
                    return (nil, .nsError(res2.err!));
                }
            }
        }

        path! += filename;
        return NSFileManager.defaultManager().createFileAtPath(path!, contents: nil, attributes: nil) ? (path, nil) : (nil, .unknown("Failed at creating '\(path)'"));
    }

    private class func getCompletePathWith(#basedir: String, subdir: String) -> (path: String?, err: pMgrErr?) {

        let completePath: String = basedir + (basedir.hasSuffix("/") ? "" : "/") + subdir;
        let fmgr: NSFileManager = NSFileManager.defaultManager();
        var isDir: ObjCBool = false;

        if (fmgr.fileExistsAtPath(completePath, isDirectory: &isDir)) {
            return (Bool(isDir) == true) ? (completePath, nil) : (nil, pMgrErr.fileExists);
        }
        return (nil, pMgrErr.noDir);
    }

    private class func buildPathFrom(basedir: String, subdir: String) -> (path: String?, err: NSError?) {

        let completePath: String = basedir + (basedir.hasSuffix("/") ? "" : "/") + subdir;
        let fmgr: NSFileManager = NSFileManager.defaultManager();
        var err: NSError? = nil;

        fmgr.createDirectoryAtPath(completePath, withIntermediateDirectories: true, attributes: nil, error: &err)

        return (err == nil) ? (completePath, nil) : (nil, err);
    }
}