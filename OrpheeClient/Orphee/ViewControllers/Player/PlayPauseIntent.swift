//
//  PlayPauseIntent.swift
//  Orphee
//
//  Created by John Bobington on 02/03/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import UIKit


class playButtonIntent: NSObject {
    @IBOutlet weak var player: MiniPlayer!
    @IBOutlet weak var timerManager: TimerManager!

    @IBAction func pressPlay() {
        self.timerManager.stop()

        self.player.playPause()
        if self.player.isPlaying {
            self.timerManager.start()
        }
    }
}
//
//class PlayPauseIntent: NSObject {
//
//    @IBOutlet weak var playButton: UIButton?
//    @IBOutlet weak var playerController: PlayerViewController!
//    @IBOutlet weak var timerIntent: TimerManager!
//
//    var testTimer: NSTimer?
//
//    let pauseImage = UIImage(named: "player/stop")!
//    let playImage = UIImage(named: "player/play")!
//
//    var isPlaying: Bool {
//        return playerController.parentVC.isPlaying
//    }
//
//    var buttonTitle: UIImage {
//        if isPlaying { return  pauseImage}
//        else { return playImage }
//    }
//
//    @IBAction func pressPlayStarted(sender: UIButton) {
////        playButton?.imageView?.tintColor = UIColor.randomColor()
//    }
//
//    @IBAction func pressPlay() {
//        timerIntent.timer?.invalidate()
//
//        self.playerController.playPause()
//        self.playButton?.setImage(self.buttonTitle, forState: .Normal)
//        if self.isPlaying {
//            self.timerIntent.timer = NSTimer.every(0.1.seconds, act: playerController.updateElapsedTime)
//        }
//    }
//
////    @IBAction func delPlayer() {
////        self.playerController.player = nil
////    }
////
//    func updateUI() {
//        self.playButton?.setImage(self.buttonTitle, forState: .Normal)
//    }
//}
