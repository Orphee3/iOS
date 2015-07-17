//
//  AudioPlayer.swift
//  Orphee
//
//  Created by JohnBob on 12/07/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

protocol AudioPlayer {

    weak var session: AudioSession? { get };
    weak var audioGraph: AudioGraph? { get };

    var player: MusicPlayer { get };

    init(graph: AudioGraph, session: AudioSession);
    
    func play();
    func pause();
    func stop();
    func clean();
}