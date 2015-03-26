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
/// TODO: This class is a mess. Fix it.
class PathManager {

    ///    An enumeration of the different errors that `PathManager` might encounter.
    ///
    ///    - fileExists: A file with the given name already exists.
    ///    - noDir:      No directory with the given name exists.
    ///    - nsError:    An internal error occured. See the related `NSError` for more information.
    ///    - unknown:    An unspecified error occured. See the related `String` for more information.
    enum PathMgrErr {
        case fileExists
        case noDir
        case nsError(NSError)
        case unknown(String)
    }

    ///    Creates the `filename` file in the given subdirectory of the bundle's resource directory.
    ///
    ///    :param: filename The name of the file to be created.
    ///    :param: dir      The subdirectory in which to create the file.
    ///
    ///    :returns: A pair of optionals.
    ///    :returns:    - `path` is nil on error. Otherwise it's the new file's path.
    ///                 - `err` is nil if no error is encountered. Otherwise it is set with the corresponding value.
    class func createResourceFile(filename: String, subdirectory dir: String? = nil) -> (path: String?, err: PathMgrErr?) {

        let resourcePath: String = NSBundle.mainBundle().resourcePath!;
        var path: String        = resourcePath;

        if let subdir = dir {
            let res = PathManager.getCompletePathWith(basedir: resourcePath, subdir: subdir);

            if (res.path == nil) {
                let res2 = PathManager.buildPathFrom(resourcePath, subdir: subdir);

                if (res2.path == nil) {
                    return (nil, PathMgrErr.nsError(res2.err!));
                }
                else {
                    path = res2.path!;
                }
            }
            else {
                path = res.path!;
            }
        }

        path += filename;
        return (NSFileManager.defaultManager().createFileAtPath(path, contents: nil, attributes: nil)
                ? (path, nil)
                : (nil, PathMgrErr.unknown("Failed at creating '\(path)'"))
        );
    }

    ///    Provides the complete path given a base directory and it's subdirectory. Checks for errors.
    ///
    ///    :param: basedir The base directory path.
    ///    :param: subdir  The subdirectory's path from the given base directory.
    ///
    ///    :returns: A pair of optionals.
    ///    :returns:    - `path` is nil on error. Otherwise it is the complete path.
    ///                 - `err` is nil if no error is encountered. Otherwise it is set with the corresponding value.
    private class func getCompletePathWith(#basedir: String, subdir: String) -> (path: String?, err: PathMgrErr?) {

        let completePath: String = basedir + (basedir.hasSuffix("/") ? "" : "/") + subdir;
        let fmgr: NSFileManager  = NSFileManager.defaultManager();
        var isDir: ObjCBool      = false;

        if (fmgr.fileExistsAtPath(completePath, isDirectory: &isDir)) {
            return (Bool(isDir) == true) ? (completePath, nil) : (nil, PathMgrErr.fileExists);
        }
        return (nil, PathMgrErr.noDir);
    }

    ///    Creates the directory tree corresponding to the given paths.
    ///
    ///    :param: basedir The base directory from wich to build the tree.
    ///    :param: subdir  The subdirectory tree.
    ///
    ///    :returns: A pair of optionals.
    ///    :returns:    - `path` is nil on error. Otherwise it is the path to the last subdirectory of the created tree.
    ///                 - `err` is nil if no error is encountered. Otherwise it is set with the corresponding value.
    private class func buildPathFrom(basedir: String, subdir: String) -> (path: String?, err: NSError?) {

        let completePath: String = basedir + (basedir.hasSuffix("/") ? "" : "/") + subdir;
        let fmgr: NSFileManager  = NSFileManager.defaultManager();
        var err: NSError?        = nil;

        fmgr.createDirectoryAtPath(completePath, withIntermediateDirectories: true, attributes: nil, error: &err)

        return (err == nil) ? (completePath, nil) : (nil, err);
    }
}