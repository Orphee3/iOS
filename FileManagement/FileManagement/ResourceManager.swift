//
//  ResourceManager.swift
//  FileManagement
//
//  Created by JohnBob on 25/03/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation

///    Classes charged with managing resources for an iOS app should follow this protocol.
public protocol ResourceManager {

    func createResource(path: String) -> Bool;
    func deleteResource() -> Bool;
}
