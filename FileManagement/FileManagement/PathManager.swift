//
//  PathManager.swift
//  FileManagement
//
//  Created by JohnBob on 10/09/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import UIKit

///    An enumeration of the different errors that `PathManager` might encounter.
///
///    - noDir:      No directory with the given name exists.
///    - unknown:    An unspecified error occured. See the related `String` for more information.
public enum ePathMgrErr: ErrorType {
    case noDir
    case unknown(String)
}

/** PathManager class

*/
public class PathManager {


    public class func listFiles(path: String, fileExtension ext: String? = nil) throws -> [String] {
        guard let iter: NSDirectoryEnumerator = NSFileManager.defaultManager().enumeratorAtPath(path)
            else {
                throw ePathMgrErr.unknown("Got nil directory enumerator for path: \(path)")
        }
        var list: [String] = [];
        let filler: ((NSString) -> Void)!
        if let ex = ext {
            filler = { entry -> Void in
                if entry.pathExtension.lowercaseString == ex.lowercaseString {
                    list.append(String(entry))
                }
            }
        }
        else {
            filler = { entry -> Void in
                list.append(String(entry));
            }
        }
        iter.allObjects.forEach() { filler($0 as! NSString) }
        return list;
    }
}
