//
//  TimerIntent.swift
//  Orphee
//
//  Created by John Bobington on 02/03/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import UIKit

class TimerIntent: NSObject {
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var position: UILabel!

    var timer: NSTimer?

    func formatTimeValue(time: Float) -> String {
        let tm = 120 * time
        let minutes = Int(floorf(roundf(tm) / 60));
        let seconds = Int(roundf(tm)) - (minutes * 60);

        return NSString(format: "%d:%02d", minutes, seconds) as String
    }

    func updateElapsedTime() {
        position?.text = formatTimeValue(slider.value)
    }
}
