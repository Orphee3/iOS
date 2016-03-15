//
//  PlayerViewController.swift
//  Orphee
//
//  Created by John Bobington on 02/03/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import UIKit
import AVKit
import FileManagement

class PlayerViewController: UIViewController, pCreationListActor {

    var player: MIDIPlayer?;
    var audioIO: AudioGraph = AudioGraph();
    var session: AudioSession = AudioSession();

    @IBOutlet weak var trackTitle: UIBarButtonItem!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var elapsedTimeLbl: UILabel!

    @IBOutlet weak var sliderIntent: SliderIntent!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupAudio()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "creationListSegue") {
            let creationList = segue.destinationViewController as! CreationsListVC;
            creationList.mainVC = self;
        }
    }

    func setupAudio() {
        self.session.setupSession(&audioIO);
        self.audioIO.createAudioGraph();
        self.audioIO.configureAudioGraph();
        self.audioIO.startAudioGraph();
    }

    func playPause() {
        if let pl = player where pl.isPlaying {
            pl.pause()
        }
        else if let pl = player {
            pl.play()
        }
        updateElapsedTime()
    }

    func actOnSelectedCreation(creation: String) {

        let path = MIDIFileManager(name: creation).path

        player = try! MIDIPlayer(path: path)
        player?.setupAudioGraph()
        trackTitle.title = creation
        durationLbl.text = self.player?.formatTime(self.player!.duration)
        sliderIntent.updateMaxValue(Float(player!.duration))
    }

    func updateElapsedTime() {
        let currentTime = player!.currentTime
        elapsedTimeLbl?.text = player?.formatTime(currentTime)
        sliderIntent.updateCurrentValue(Float(currentTime))
    }
}
