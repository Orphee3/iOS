//
//  eAccessMode.swift
//  FileManagement
//
//  Created by Massil on 14/07/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit

///    The different access modes available.
public enum eAccessMode {
    ///    Read access only. Writting is impossible.
    case Readonly
    ///    Write access only. Reading is impossible.
    case Writeonly
    ///    Read and write access.
    case ReadWrite
}

