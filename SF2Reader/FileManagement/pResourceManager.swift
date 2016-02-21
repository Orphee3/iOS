//
//  pResourceManager.swift
//  FileManagement
//
//  Created by JohnBob on 25/03/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation

///    Classes charged with managing resources for an iOS app should follow this protocol.
public protocol pResourceManager {

    ///  Creates ressource file at given path.
    ///
    ///  - parameter path: The path leading to the resource file.
    ///
    ///  - returns: `true` on success, `false` on failure.
    func createResource(path: String) -> Bool;
    
    ///  Deletes the managed resource
    ///
    ///  - returns: `true` on success, `false` on failure.
    func deleteResource() -> Bool;
}
