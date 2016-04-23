//
//  TimerIntent.swift
//  Orphee
//
//  Created by John Bobington on 02/03/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import UIKit

class TimerManager: NSObject {
    @IBOutlet weak var sliderIntent: SliderIntent!

    @IBOutlet weak var player: MiniPlayer!

    var mainTimer: NSTimer?
    var preciseTimer: NSTimer?
    var wasPlaying: Bool = false

    var playStateChanged: Bool {
        return self.wasPlaying != self.player.isPlaying
    }

    func start() {
        self.preciseTimer = NSTimer.every(100.milliSeconds) { [weak self] in
            if let this = self {
                this.sliderIntent.updateCurrentValue(this.player.currentTime)
                this.player.updateTimeUI()
                if this.playStateChanged {
                    this.player.updatePlayButton()
                    this.wasPlaying = this.player.isPlaying
                }
            }
        }
    }

    func stop() {
        self.mainTimer?.invalidate()
        self.preciseTimer?.invalidate()
    }
}
