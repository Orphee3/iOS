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

    func formatTimeValue(var time: Float) -> String {
        time *= 120
        let minutes = Int(floorf(roundf(time) / 60));
        let seconds = Int(roundf(time)) - (minutes * 60);

        return NSString(format: "%d:%02d", minutes, seconds) as String
    }

    func updateElapsedTime() {
        position?.text = formatTimeValue(slider.value)
    }
}
