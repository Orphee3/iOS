//
//  pInputManager.swift
//  FileManagement
//
//  Created by JohnBob on 15/07/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation

///    Common interface for reading from files, sockets and the like.
public protocol pInputManager {

    ///    Reads all the data contained in the given target.
    ///
    ///    - returns: The data that has been read.
    func readAllData() -> NSData;

    ///    Reads the given number of bytes from the target.
    ///
    ///    - parameter size: The number of bytes to read.
    ///
    ///    - returns: The data that has been read.
    func read(size size: UInt) -> NSData;
}
