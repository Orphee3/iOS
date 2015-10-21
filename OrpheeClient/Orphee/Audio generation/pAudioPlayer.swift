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

protocol pAudioPlayer {

    var playing: Bool { get set };

    init(graph: AudioGraph, session: AudioSession);

    mutating func play(data: NSData);
    mutating func pause();
    mutating func stop();
}

protocol pAudioPlayerWithDataSource: pAudioPlayer {
    typealias audioDataType;

    var audioData: audioDataType { get };

    mutating func play();
    init(graph: AudioGraph, session: AudioSession, audioData: audioDataType);
}
