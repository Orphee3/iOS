//
//  pAudioPlayer.swift
//  Orphee
//
//  Created by JohnBob on 12/07/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

protocol pMediaPlayer {

    var isPlaying: Bool { get }

    func play()
    func pause()
}

protocol pMediaPlayerTimeManager {

    var duration: NSTimeInterval { get }
    var currentTime: NSTimeInterval { get set }

    func formatTime(time: NSTimeInterval) -> String
}
