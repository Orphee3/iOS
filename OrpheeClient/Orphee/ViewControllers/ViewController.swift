//
//  ViewController.swift
//  Orphee
//
//  Created by John Bob on 29/01/15.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit
import MIDIToolbox
import FileManagement

/// The app's main view controller
class ViewController: UIViewController {

    /// The scroll view containing the composition area
    @IBOutlet weak var scrollBlocks: UIScrollView!

    @IBOutlet var stepper: UIStepper!

    @IBOutlet weak var trackBar: UIToolbar!

    /// A dictionary with as key, the track name and as value, a corresponding wrapper around a UITrackTimeBlock array.
    var tracks: [BlockArrayList?] = []
    var tracksInfo: [[String : Any]?] = []

    var currentTrack: Int = 0

    var player: pAudioPlayer!;
    var audioIO: AudioGraph = AudioGraph();
    var session: AudioSession = AudioSession();

    var fileForSegue: String?

    var oldValue: Int {
        get {
            guard self.currentTrack < self.tracks.count else {
                return 0
            }
            return self.tracks[self.currentTrack]?.blockLength ?? 0
        }
    }

    var importAction: ((UIAlertAction!) -> Void)!
    var saveAction: ((UIAlertAction!) -> Void)!
    var cancelAction: ((UIAlertAction!) -> Void)!

    var fileNbr: Int = 0;

    /// MARK: Overrides
    //

    /// Called when this controller's view is loaded.
    override func viewDidLoad() {
        super.viewDidLoad();

        addTrack(self)
        session.setupSession(&audioIO);
        audioIO.createAudioGraph();
        audioIO.configureAudioGraph();
        audioIO.startAudioGraph();

        if let data = NSUserDefaults.standardUserDefaults().objectForKey("myUser") as? NSData {
            let user = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! User
            eCreationRouter.userID = user.id
            eCreationRouter.OAuthToken = user.token
        }

        player = LiveAudioPlayer(graph: audioIO, session: session);
        makeActions();
        if let segueFile = fileForSegue {
            self.importFile(segueFile)
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBarHidden = true
    }

    /// Called when the app consumes too much memory.
    /// Dispose of any resources that can be recreated.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        navigationController?.navigationBarHidden = false
        if (segue.identifier == "instrumentsSegue") {
            let instrus = segue.destinationViewController as! InstrumentsTableViewController;
            instrus.mainVC = self;
        }
        else if (segue.identifier == "creationListSegue") {
            print("segueseguesegue")
            let creationList = segue.destinationViewController as! CreationsListVC;
            creationList.mainVC = self;
        }
    }

    /// MARK: Utility methods
    //

    func createTracks(trackCount: Int) {
        for _ in 0..<trackCount {
            let block = BlockArrayList();
            createBlocks(block, columns: 1);
            tracks.append(block);
        }
        print("track count \(tracks.count)");
        print(tracks);
        updateScrollViewConstraints();
    }

    /// Creates a track for each entry in `instrumentsList` with `columns` number of columns.
    /// Each track is added to `dictBlocks` with the corresponding instrument as key.
    /// Each track is added as a subview to `scrollBlocks` and updates the scroll view's size.
    ///
    /// - parameter columns:  The number of columns to add to each track.
    func createBlocks(blockArrays: BlockArrayList, columns: Int) {

        for idx in 0...12 {

            let track: UITimeBlockArray = UITimeBlockArray(rowNbr: idx, noteValue: 60 - idx, inView: scrollBlocks, withGraph: audioIO);

            blockArrays.blockArrays.append(track);
            track.addButtons(columns, color: UIColor.blueColor());
        }
        blockArrays.updateProperties();
    }

    func updateScrollViewConstraints() {

        if self.tracks.count > 0 {
        scrollBlocks.contentSize = CGSizeMake(
            CGFloat(self.tracks[self.currentTrack]?.endPos.x ?? 0),
            CGFloat(self.tracks[self.currentTrack]?.endPos.y ?? 0)
        );
        }
    }

    func makeActions() {
        importAction = { (alert: UIAlertAction!) -> Void in

            print("File imported")
            self.performSegueWithIdentifier("creationListSegue", sender: self);
        };

        saveAction = { (alert: UIAlertAction!) -> Void in

            print("File Saved")
            let tracks: [String : Any]? = [
                    eOrpheeFileContent.Tracks.rawValue : self.prepareTracksForSave(),
                    eOrpheeFileContent.TracksInfos.rawValue : self.tracksInfo
            ];
            let fm = MIDIFileManager(name: "test\(self.fileNbr).mid");
            fm.createFile()
            fm.writeToFile(content: tracks, dataBuilderType: CoreMIDISequenceCreator.self);
            OrpheeApi().sendCreationToServer(eCreationRouter.userID!, name: fm.name, completion: { print($0) });
            try? NSFileManager.defaultManager().copyItemAtPath(fm.path, toPath: "/Users/johnbob/Desktop/\(fm.name)");
            ++self.fileNbr;
        };

        cancelAction = { (alert: UIAlertAction!) -> Void in

            print("Cancelled")
        };
    }

    func prepareTracksForSave() -> [Int : [[MIDINoteMessage]]]{
        var trks = [Int : [[MIDINoteMessage]]]()
        for (idx, track) in tracks.enumerate() {
            trks[idx] = track!.getFormattedNoteList()
        }
        return trks;
    }

    func importFile(file: String) {
        resetAll()
        self.updateScrollViewConstraints();
        let data: [String : Any] = MIDIFileManager(name: file).readFile()!;
//        print(data)
        for (key, value) in data {
            if var trackList = value as? [Int : [[Int]]]
               where key == eOrpheeFileContent.Tracks.rawValue {
                    currentTrack = 0;
                    for idx in 0..<trackList.count {
                        let track = trackList[idx]!
                        let blockArray = BlockArrayList();
                        trackBar.items?.insert(UIBarButtonItem(title: "\(idx + 1)", style: UIBarButtonItemStyle.Plain, target: self, action: "changeTrack:"), atIndex: tracks.count)
                        createBlocks(blockArray, columns: 1);
                        blockArray.hide();
                        let missingBlocks = track.count - blockArray.blockLength;
                        if (missingBlocks > 0) {
                            blockArray.addBlocks(missingBlocks);
                            self.stepper.value = Double(self.oldValue);
                        }
                        blockArray.setBlocksFromList(track);
                        tracks.append(blockArray)
                    }
                    if let infoList = value as? [[String : Any]]
                        where key == eOrpheeFileContent.TracksInfos.rawValue {
                            for (idx, info) in infoList.enumerate() {
                                if let patch = info[eOrpheeFileContent.PatchID.rawValue] as? Int {
                                    tracksInfo[idx] = [eOrpheeFileContent.PatchID.rawValue : patch];
                                }
                            }
                    }
            }
        }
        changeTrack(trackIdx: 0);
        self.updateScrollViewConstraints();
    }

    func resetAll() {
        for track in tracks {
            track!.resetBlocks()
            if let removedItem = trackBar.items?.removeFirst()
                where removedItem.action != "changeTrack:" {
                    trackBar.items?.insert(removedItem, atIndex: 0);
            }

        }
        tracks.removeAll();
        tracksInfo.removeAll();
    }

    func changeTrack(trackIdx idx: Int) {
        for track in tracks {
            track!.hide();
        }
        currentTrack = idx;
        tracks[currentTrack]?.show()
        stepper.value = Double(oldValue)
        print("current track \(currentTrack)")
    }

    /// MARK: UI action responders
    //

    @IBAction func cleanAll(sender: AnyObject) {
        resetAll();
    }

    @IBAction func changeTrack(sender: AnyObject) {
        if let button = sender as? UIBarButtonItem {
            changeTrack(trackIdx: Int(button.title ?? "1")! - 1);
        }
    }

    @IBAction func addTrack(sender: AnyObject) {
        trackBar.items?.insert(UIBarButtonItem(title: "\(tracks.count + 1)", style: UIBarButtonItemStyle.Plain, target: self, action: "changeTrack:"), atIndex: tracks.count)
        createTracks(1);
        if let idx = tracks.count - 1 as Int? where tracks.count > 0 {
            changeTrack(trackIdx: idx)
        }
    }

    @IBAction func addAndRemoveBlocks(sender: UIStepper) {
        print(sender.value)
        if (Int(sender.value) > oldValue) {
            print(oldValue);
            tracks[currentTrack]?.addBlocks(1);
            updateScrollViewConstraints();
        }

        else if (oldValue > 1) {
            tracks[currentTrack]?.removeBlocks(1);
            updateScrollViewConstraints();
        }
    }

    /// Called when the UI's `Stop` button is pressed.
    /// Displays *stop*
    ///
    /// - parameter sender:  The object sending the event.
    @IBAction func StopButtonTouched(sender: AnyObject) {
        player.pause();
    }

    /// Called when the UI's `Play` button is pressed.
    /// Displays *play*
    ///
    /// - parameter sender:  The object sending the event.
    @IBAction func PlayButtonTouched(sender: AnyObject) {
        _ = sender as! UIBarButtonItem;

        if let p = player as? LiveAudioPlayer,
            let track = tracks[currentTrack]
            where player is pAudioPlayerWithDataSource && !player.playing {
            p.audioData = track.getCleanedList();
            p.play();
        }
    }

    @IBAction func FileButtonTouched(sender: AnyObject) {
        let optionMenu = UIAlertController(title: nil, message: "Choisissez une option", preferredStyle: .ActionSheet)

        let importAction = UIAlertAction(title: "Importer", style: .Default, handler: self.importAction);
        let saveAction = UIAlertAction(title: "Sauvegarder", style: .Default, handler: self.saveAction)
        let cancelAction = UIAlertAction(title: "Annuler", style: .Cancel, handler: self.cancelAction)

        optionMenu.addAction(importAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
}

