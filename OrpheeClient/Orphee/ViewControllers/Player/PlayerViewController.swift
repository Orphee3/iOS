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


class MiniPlayer: UIViewController, pCreationListActor {
    var player: MIDIPlayer?
    var audioIO: AudioGraph = AudioGraph()
    var session: AudioSession = AudioSession()

    let pauseImage = UIImage(named: "player/stop")!
    let playImage = UIImage(named: "player/play")!

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var trackTitle: UILabel!
    @IBOutlet weak var trackImage: UIImageView!
    @IBOutlet weak var sliderIntent: SliderIntent!
    @IBOutlet weak var timerManager: TimerManager!
    @IBOutlet weak var playBtnIntent: playButtonIntent!

    lazy var maxPlayer: PlayerViewController = { [weak self] in
        let sb = UIStoryboard(name: "Player", bundle: nil)
        let maxPlayer = sb.instantiateViewControllerWithIdentifier("MaxPlayer") as! PlayerViewController
        maxPlayer.modalPresentationStyle = .OverFullScreen
        maxPlayer.parentVC = self
        return maxPlayer
    }()

    var isPlaying: Bool {
        return self.player?.isPlaying == .Some(true)
    }

    var buttonTitle: UIImage {
        if self.isPlaying { return self.pauseImage}
        else { return self.playImage }
    }

    var currentTime: NSTimeInterval {
        return self.player?.currentTime ?? 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.sliderIntent = maxPlayer.sliderIntent
        self.timerManager.sliderIntent = self.sliderIntent
        setupAudio()
    }


    func setupAudio() {
        self.session.setupSession(&audioIO);
        self.audioIO.createAudioGraph();
        self.audioIO.configureAudioGraph();
        self.audioIO.startAudioGraph();
    }

    func playPause() {
        print("MinPlayer playPause")
        switch self.player?.isPlaying {
        case .Some(true):
            self.player?.stop()
        case .Some(false):
            self.player?.play()
        default:
            break
        }
        self.maxPlayer.playPause()
    }

    func actOnSelectedCreation(creation: String) {

        let path = MIDIFileManager(name: creation).path

        guard let player = try? MIDIPlayer(path: path) else {
            DefaultErrorAlert.makeAndPresent("Le lecteur a rencontré l'erreur suivante:", message: "Impossible d'ouvrir le fichier à l'emplacement suivant: \(path)")
            return
        }
        self.player = player
        self.player!.setupAudioGraph()
    }

    func updatePlayButton() {
        self.playButton.setImage(self.buttonTitle, forState: .Normal)
        self.maxPlayer.playBtn.setImage(self.buttonTitle, forState: .Normal)
    }

    func updateTimeUI() {
        self.maxPlayer.updateTimeUI()
    }

    @IBAction func maximize() {
        self.presentViewController(maxPlayer, animated: true, completion: nil)
    }
}



class PlayerViewController: UIViewController, pCreationListActor {

    weak var parentVC: MiniPlayer!

    var blurView: UIVisualEffectView!

    @IBOutlet weak var trackTitle: UILabel!
    @IBOutlet weak var trackImage: UIImageView!
    @IBOutlet weak var trackLengthLbl: UILabel!
    @IBOutlet weak var trackElapsedTimeLbl: UILabel!

    @IBOutlet weak var repeatBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var prevBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var sliderIntent: SliderIntent!

    @IBOutlet weak var contentView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.playBtn.addTarget(self.parentVC.playBtnIntent, action: #selector(playButtonIntent.pressPlay), forControlEvents: .TouchUpInside)
        self.setupBlurView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
        updateTimeUI()
        updateTrackUI(nil)
        self.blurView.frame = self.view.bounds
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.blurView.frame = self.view.bounds
    }

    override func viewDidDisappear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
        super.viewDidDisappear(animated)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "creationListSegue") {
            let creationList = segue.destinationViewController as! CreationsListVC;
            creationList.mainVC = self;
        }
    }

    func setupBlurView() {
        let blur = UIBlurEffect(style: .ExtraLight)
        let blurView = UIVisualEffectView(effect: blur)
        self.view.addSubview(blurView)
        self.view.sendSubviewToBack(blurView)
        self.blurView = blurView
    }

    // MARK:
    func playPause() {
        print("MaxPlayer playPause")
//        self.parentVC.playPause()
    }

    func actOnSelectedCreation(creation: String) {

        parentVC.actOnSelectedCreation(creation)
        updateTimeUI()
        updateTrackUI(creation)
        trackTitle.text = creation
    }

    func updateTrackUI(name: String?) {
        if let name = name {
            let image = getImageForTrack(name)
            trackImage.image = image
        }
        if let _ = self.parentVC.player {
            self.trackTitle.hidden = false
        } else {
            self.trackTitle.hidden = true
        }
    }

    func updateTimeUI() {
        let player = self.parentVC.player
        trackElapsedTimeLbl.text = MIDIPlayer.formatTime(player?.currentTime ?? 0)
        trackLengthLbl.text = MIDIPlayer.formatTime(player?.duration ?? 0)
    }

    func getImageForTrack(name: String) -> UIImage {
        print(name)

        return UIImage(named: "emptyfunprofile")!
    }

    @IBAction func pressNext() {
        if let paths = try? PathManager.listFiles(NSHomeDirectory() + "/Documents/AlbumArt") {
            let albumName = paths[paths.startIndex.advancedBy(Int(arc4random_uniform(UInt32(paths.count))))]
            updateTrackUI(albumName)
        }
    }

    let repeatOne = UIImage(named: "player/repeat/one")!
    let repeatNone = UIImage(named: "player/repeat/none")!

    var repeatCnt = repeatCount.none

    @IBAction func pressRepeat() {
        switch repeatCnt {
        case .none:
            repeatCnt = .one
            repeatBtn.setImage(repeatOne, forState: .Normal)
            self.parentVC.player?.repeats = true
        default:
            repeatCnt = .none
            repeatBtn.setImage(repeatNone, forState: .Normal)
            self.parentVC.player?.repeats = false
        }
    }

    @IBAction func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
