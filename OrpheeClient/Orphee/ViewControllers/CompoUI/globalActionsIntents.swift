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
        let optionMenu = UIAlertController(title: nil, message: "Choisissez une option", preferredStyle: .ActionSheet)
        
        let importAction = UIAlertAction(title: "Importer", style: .Default, handler: self.VC.importAction);
        let tempoAction = UIAlertAction(title: "Choisir le tempo", style: .Default, handler: self.VC.tempoAction);
        let saveAction = UIAlertAction(title: "Sauvegarder", style: .Default, handler: self.VC.saveAction)
        let cancelAction = UIAlertAction(title: "Annuler", style: .Cancel, handler: self.VC.cancelAction)
        
        optionMenu.addAction(tempoAction)
        optionMenu.addAction(importAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        self.VC.presentViewController(optionMenu, animated: true, completion: nil)
    }
}
