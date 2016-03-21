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

    let pauseImage = UIImage(named: "player/pause")!
    let playImage = UIImage(named: "player/play")!
    let defaultColor = UIColor(r: 0x33, g: 0x33, b: 0x33, alpha: 1)

    var isPlaying: Bool {
        if let pl = playerController.player where pl.isPlaying {
            return true
        }
        return false
    }

    var buttonTitle: UIImage {
        if isPlaying { return  pauseImage}
        else { return playImage }
    }

    @IBAction func pressPlayStarted(sender: UIButton) {
        playButton?.imageView?.tintColor = UIColor.randomColor()
    }

    @IBAction func pressPlay(sender: UIButton) {
        timerIntent.timer?.invalidate()

        self.playerController.playPause()
        self.playButton?.setImage(self.buttonTitle, forState: .Normal)
        if self.isPlaying {
            self.timerIntent.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: playerController, selector: Selector("updateElapsedTime"), userInfo: nil, repeats: true)
        }
        playButton?.imageView?.tintColor = defaultColor
    }

    @IBAction func delPlayer() {
        self.playerController.player = nil
    }
}
