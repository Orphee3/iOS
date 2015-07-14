//
//  eAccessMode.swift
//  FileManagement
//
//  Created by Massil on 14/07/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit

///    The different access modes available.
///
///    - Readonly:  Read access only. Writting is impossible.
///    - Writeonly: Write access only. Reading is impossible.
///    - ReadWrite: Read and write access.
public enum eAccessMode {
    case Readonly
    case Writeonly
    case ReadWrite
}

