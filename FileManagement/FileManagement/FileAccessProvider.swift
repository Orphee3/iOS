//
//  FileAccessProvider.swift
//  FileManagement
//
//  Created by Massil on 25/03/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit

/// Class FileAccessProvider
///
/// A wrapper arround NSFileHandle. Provides the correct File Handle object for a given file and operation.
class FileAccessProvider: IOManager {

    ///    Provides a file handler for the given file and operation.
    ///
    ///    :param: path The path to the file.
    ///    :param: mode The access rights needed.
    ///
    ///    :returns:    - An NSFileHandle to the given path.
    ///                 - Or nil if no file is found at the given path.
    class func getFileHandle(forPath path: String, mode: AccessMode) -> NSFileHandle? {

        var handler: NSFileHandle?;

        switch mode {
        case .Readonly:
            handler = NSFileHandle(forReadingAtPath: path);
        case .Writeonly:
            handler = NSFileHandle(forWritingAtPath: path);
        case .ReadWrite:
            handler = NSFileHandle(forUpdatingAtPath: path);
        }
        return handler.writeabilityHandler;
    }
}