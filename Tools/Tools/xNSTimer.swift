//
//  xNSTimer.swift
//  Tools
//
//  Created by John Bobington on 31/03/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import Foundation

private class NSTimerActor {
    var block: () -> ()

    init(block: () -> ()) {
        self.block = block
    }

    @objc func fire() {
        block()
    }
}


public extension NSTimer {
    class func after(interval: NSTimeInterval, act block: () -> ()) -> NSTimer {
        let actor = NSTimerActor(block: block)
        let timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: actor, selector: #selector(NSTimerActor.fire), userInfo: nil, repeats: false)
        return timer
    }

    class func every(interval: NSTimeInterval, act block: () -> ()) -> NSTimer {
        let actor = NSTimerActor(block: block)
        let timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: actor, selector: #selector(NSTimerActor.fire), userInfo: nil, repeats: true)
        return timer
    }
}