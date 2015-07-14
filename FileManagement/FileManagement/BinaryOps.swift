//
//  BinaryOps.swift
//  FileManagement
//
//  Created by JohnBob on 14/07/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation


public func swapUInt32(i: UInt32) -> UInt32
{
    var half1: UInt32 = ((i & 0xFF000000) >> 24) | ((i & 0x00FF0000) >> 8);
    var half2: UInt32 = ((i & 0x0000FF00) << 8) | ((i & 0x000000FF) << 24);
    return  half1 | half2;
}

public func swapUInt16(i: UInt16) -> UInt16
{
    return ((i & 0xFF00) >> 8) | ((i & 0x00FF) << 8);
}