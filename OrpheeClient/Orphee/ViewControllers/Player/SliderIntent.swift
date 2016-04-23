//
//  SliderIntent.swift
//  Orphee
//
//  Created by John Bobington on 02/03/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import UIKit

class SliderIntent: NSObject {

    @IBOutlet weak var slider: UISlider?
    @IBOutlet weak var player: MiniPlayer!

    var isSliding: Bool = false

    @IBAction func sliding(sender: UISlider) {
        isSliding = true
    }

    @IBAction func stopSlide(sender: UISlider) {
        isSliding = false
        let _ = NSTimer.after(0.seconds, act: player.updateTimeUI)
    }

    func updateMaxValue(value: Float) {
        slider?.maximumValue = value;
        slider?.minimumValue = 0
        slider?.value = 0
    }

    func updateCurrentValue(value: NSTimeInterval) {
        if !self.isSliding {
            slider?.value = Float(value)
        }
    }
}
