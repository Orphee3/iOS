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
        let _ = NSTimer.after(0.seconds, act: timerIntent.updateElapsedTime)
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
