//
//  globalActionsIntents.swift
//  Orphee
//
//  Created by John Bobington on 28/01/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import UIKit
import MIDIToolbox
import FileManagement

class globalActionsIntents: NSObject {

    @IBOutlet weak var VC: CompositionVC!
    @IBOutlet weak var trackBarOps: trackBarOpsIntent!

    @IBAction func playButtonTouched(sender: AnyObject) {
        print("play")
        //        self.VC.saveFile()
        let content = self.VC.content
        print(content)
        if let data = MIDIFileManager.toData(content: content, dataBuilderType: CoreMIDISequenceCreator.self) {
            self.VC.player = MIDIPlayer(data: data)
            self.VC.player?.setupAudioGraph()
            self.VC.player?.play()
        }
    }

    @IBAction func pauseButtonTouched(sender: AnyObject) {
        print("stop")
    }


    @IBAction func actionButtonTouched(sender: AnyObject) {
        self.VC.presentActions()
    }
    
    @IBAction func cleanAll() {
        self.VC.cleanData()
        self.trackBarOps.deleteAll()
    }
}
