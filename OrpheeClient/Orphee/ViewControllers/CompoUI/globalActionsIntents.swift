//
//  globalActionsIntents.swift
//  Orphee
//
//  Created by John Bobington on 28/01/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import UIKit
import FileManagement

class globalActionsIntents: NSObject {

    @IBOutlet weak var VC: CompositionVC!
    
    @IBAction func playButtonTouched(sender: AnyObject) {
        print("play")
        self.VC.saveFile()
        let fm = MIDIFileManager(name: self.VC.fileForSegue ?? "test\(self.VC.fileNbr - 1).mid")
        let data = fm.getFileData()
        if let player = MIDIPlayer(data: data) {
            self.VC.player = player
            if self.VC.player!.setupAudioGraph() {
                self.VC.player!.play()
            }
        }
    }
    
    @IBAction func pauseButtonTouched(sender: AnyObject) {
        print("stop")
    }
    
    
    @IBAction func actionButtonTouched(sender: AnyObject) {
        self.VC.presentActions()
    }
}
