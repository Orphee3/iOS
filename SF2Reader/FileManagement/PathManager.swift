//
//  PathManager.swift
//  FileManagement
//
//  Created by JohnBob on 10/09/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import UIKit

///    An enumeration of the different errors that `PathManager` might encounter.
public enum ePathMgrErr: ErrorType {
    /// No directory with the given name exists.
    case noDir
    /// An unspecified error occured. See the related `String` for more information.
    case unknown(String)
}

/// The class charged with path management.
public class PathManager {

    ///  Public class methode charged with listing files in a given directory.
    ///  A file extension can be provided as a filter.
    ///
    ///  - parameter path: The path to the directory to search.
    ///  - parameter ext:  The file extension filter. No filter is applied by default.
    ///
    ///  - throws: `ePathMgrErr` value if the directory couldn't be enumerated.
    ///
    ///  - returns: An array containing the names of the files contained by the directory.
    public class func listFiles(path: String, fileExtension ext: String? = nil) throws -> [String] {
        guard let entries = NSFileManager.defaultManager().enumeratorAtPath(path) else {
            throw ePathMgrErr.unknown("Got nil directory enumerator for path: \(path)")
        }
        if let ex = ext {
            return entries.filter() { $0.pathExtension.lowercaseString == ex.lowercaseString }.map() { $0 as! String }
        }
        return entries.map() { ($0 as! String) };
    }
}
