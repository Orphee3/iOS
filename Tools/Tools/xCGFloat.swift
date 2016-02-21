//
//  xCGFloat.swift
//  Tools
//
//  Created by John Bobington on 23/01/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import Foundation

public extension CGFloat {

    static public func rand0_1CGFloat() -> CGFloat {
        return CGFloat(arc4random_uniform(256)) / CGFloat(256)
    }

    static public func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(arc4random())
    }

    static public func random(limit: UInt32) -> CGFloat {
        return CGFloat(arc4random_uniform(limit)) / CGFloat(arc4random_uniform(limit))
    }

    static public func random(limit: Int) -> CGFloat {
        return random(UInt32(limit))
    }

}