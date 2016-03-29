//
//  SliderIntent.swift
//  Orphee
//
//  Created by John Bobington on 02/03/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import UIKit

class SliderIntent: NSObject {

    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var timerIntent: TimerIntent!

    var isSliding: Bool = false

    @IBAction func sliding(sender: UISlider) {
        isSliding = true
    }

    @IBAction func stopSlide(sender: UISlider) {
        isSliding = false
        let _ = NSTimer.scheduledTimerWithTimeInterval(0.01, target: timerIntent, selector: #selector(TimerIntent.updateElapsedTime), userInfo: nil, repeats: false)
    }

    func updateMaxValue(value: Float) {
        slider.maximumValue = value;
        slider.minimumValue = 0
        slider.value = 0
    }

    func updateCurrentValue(value: Float) {
        slider.value = value
    }
}
