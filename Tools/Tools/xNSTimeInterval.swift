//
//  xNSTimeInterval.swift
//  Tools
//
//  Created by John Bobington on 31/03/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import Foundation

public extension NSTimeInterval {
    var milliSecond: NSTimeInterval { return self / 1000 }
    var milliSeconds: NSTimeInterval { return self / 1000 }
    var second: NSTimeInterval { return self }
    var seconds: NSTimeInterval { return self }
    var minute: NSTimeInterval { return self * 60 }
    var minutes: NSTimeInterval { return self * 60 }
    var hour: NSTimeInterval { return self * 3600 }
    var hours: NSTimeInterval { return self * 3600 }
}