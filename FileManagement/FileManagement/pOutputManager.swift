//
//  pOutputManagers.swift
//  FileManagement
//
//  Created by JohnBob on 25/03/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation

///    Common interface for writing to files, sockets and the like.
public protocol pOutputManager {

    ///    Writes the given data to the target.
    ///
    ///    :param: data The data to write out.
    ///
    ///    :returns:    - true:  if no error occured
    ///                 - false: otherwise
    func write(data: NSData) -> Bool;
}

