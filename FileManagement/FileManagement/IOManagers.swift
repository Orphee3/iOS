//
//  IOManagers.swift
//  FileManagement
//
//  Created by JohnBob on 25/03/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation

///    The different access modes available.
///
///    - Readonly:  Read access only. Writting is impossible.
///    - Writeonly: Write access only. Reading is impossible.
///    - ReadWrite: Read and write access.
enum AccessMode {
    case Readonly
    case Writeonly
    case ReadWrite
}

///    Common interface for writing to files, sockets and the like.
protocol OutputManager {

    ///    Writes the given data to the target.
    ///
    ///    :param: data The data to write out.
    ///
    ///    :returns:    - true:  if no error occured
    ///                 - false: otherwise
    func write(data: NSData) -> Bool;
}

///    Common interface for reading from files, sockets and the like.
protocol InputManager {

    ///    Reads all the data contained in the given target.
    ///
    ///    :returns: The data that has been read.
    func readAllData() -> NSData;

    ///    Reads the given number of bytes from the target.
    ///
    ///    :param: size The number of bytes to read.
    ///
    ///    :returns: The data that has been read.
    func read(#size: UInt) -> NSData;
}