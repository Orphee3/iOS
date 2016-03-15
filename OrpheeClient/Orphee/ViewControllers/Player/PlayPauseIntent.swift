//
//  PlayPauseIntent.swift
//  Orphee
//
//  Created by John Bobington on 02/03/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import UIKit

class PlayPauseIntent: NSObject {

    @IBOutlet weak var playButton: UIButton?
    @IBOutlet weak var playerController: PlayerViewController!
    @IBOutlet weak var timerIntent: TimerIntent!

    var testTimer: NSTimer?

    var isPlaying: Bool {
        if let pl = playerController.player where pl.isPlaying {
            return true
        }
        return false
    }

    var buttonTitle: String {
        if isPlaying { return "Pause" }
        else { return "Play" }
    }

    @IBAction func pressPlay(sender: UIButton) {
        timerIntent.timer?.invalidate()

        self.playerController.playPause()
        self.playButton?.setTitle(buttonTitle, forState: .Normal)
        if self.isPlaying {
            self.timerIntent.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: playerController, selector: Selector("updateElapsedTime"), userInfo: nil, repeats: true)
        }
    }
}
