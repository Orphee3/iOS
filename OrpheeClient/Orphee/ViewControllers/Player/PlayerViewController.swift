//
//  PlayerViewController.swift
//  Orphee
//
//  Created by John Bobington on 02/03/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import UIKit
import AVKit
import Tools
import FileManagement


public enum repeatCount {
    case all
    case one
    case none
}

class PlayerViewController: UIViewController, pCreationListActor {
    
    var player: MIDIPlayer?;
    var audioIO: AudioGraph = AudioGraph();
    var session: AudioSession = AudioSession();
    
    @IBOutlet weak var trackTitle: UILabel!
    @IBOutlet weak var trackImage: UIImageView!
    @IBOutlet weak var bkGrndImage: UIImageView!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var elapsedTimeLbl: UILabel!
    
    @IBOutlet weak var repeatBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var sliderIntent: SliderIntent!
    @IBOutlet weak var playPauseIntent: PlayPauseIntent!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupAudio()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
        if let _ = self.player {
            self.trackTitle.hidden = false
        } else {
            self.trackTitle.hidden = true
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
        super.viewDidDisappear(animated)
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
        switch self.player?.isPlaying {
        case .Some(true):
            self.player?.pause()
        case .Some(false):
            self.player?.play()
        default:
            self.actOnSelectedCreation("EIP2.mid")
            self.player?.play()
        }
        updateElapsedTime()
    }
    
    func actOnSelectedCreation(creation: String) {
        
        let path = MIDIFileManager(name: creation).path
        
        guard let player = try? MIDIPlayer(path: path) else {
            DefaultErrorAlert.makeAndPresent("Le lecteur a rencontré l'erreur suivante:", message: "Impossible d'ouvrir le fichier à l'emplacement suivant: \(path)")
            return
        }
        player?.setupAudioGraph()
        updateTimeUI()
        updateTrackUI(creation)
        trackTitle.text = creation
    }
    
    func updateElapsedTime() {
        let currentTime = player?.currentTime ?? 0
        elapsedTimeLbl?.text = MIDIPlayer.formatTime(currentTime)
        if !self.sliderIntent.isSliding {
            sliderIntent.updateCurrentValue(Float(currentTime))
        }
        if currentTime >= player?.duration ?? 0 {
            self.playPauseIntent.pressPlay()
            if repeatCnt == .one {
                self.playPauseIntent.pressPlay()
            }
        }
    }
    
    func updateTrackUI(name: String) {
        let image = getImageForTrack(name)
        trackImage.image = image
        bkGrndImage.image = UIImage.init(CGImage: image.CGImage!, scale: image.scale, orientation: .DownMirrored)
    }
    
    func getImageForTrack(name: String) -> UIImage {
        print(name)
        
        return UIImage(named: "emptyfunprofile")!
    }
    
    func updateTimeUI() {
        durationLbl.text = MIDIPlayer.formatTime(self.player!.duration)
        sliderIntent.updateMaxValue(Float(player!.duration))
    }
    
    @IBAction func pressNext() {
        let paths = try! PathManager.listFiles(NSHomeDirectory() + "/Documents/AlbumArt")
        let albumName = paths[paths.startIndex.advancedBy(Int(arc4random_uniform(UInt32(paths.count))))]
        updateTrackUI(albumName)
    }
    
    let repeatOne = UIImage(named: "player/repeat/one")!
    let repeatNone = UIImage(named: "player/repeat/none")!
    
    var repeatCnt = repeatCount.none
    
    @IBAction func pressRepeat() {
        switch repeatCnt {
        case .none:
            repeatCnt = .one
            repeatBtn.setImage(repeatOne, forState: .Normal)
        default:
            repeatCnt = .none
            repeatBtn.setImage(repeatNone, forState: .Normal)
        }
    }
}
