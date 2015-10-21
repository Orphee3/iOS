//
//  ViewController.swift
//  Orphee
//
//  Created by John Bob on 29/01/15.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit
import FileManagement

/// The app's main view controller
class ViewController: UIViewController {

    /// The scroll view containing the composition area
    @IBOutlet weak var scrollBlocks: UIScrollView!

    @IBOutlet var stepper: UIStepper!
    /// A dictionary with as key, the track name and as value, a corresponding wrapper around a UITrackTimeBlock array.
    var blockArrays: BlockArrayList = BlockArrayList();

    /// A list of all instruments supported by the app. TODO: actually implement the system.
    var instrumentsList: [String] = ["violin", "guitar", "tambour", "battery", "trumpet"];

    var player: pAudioPlayer!;
    var audioIO: AudioGraph = AudioGraph();
    var session: AudioSession = AudioSession();

    var oldValue: Int = 1;

    var importAction: ((UIAlertAction!) -> Void)!
    var saveAction: ((UIAlertAction!) -> Void)!
    var cancelAction: ((UIAlertAction!) -> Void)!

    var fileNbr: Int = 0;

    /// MARK: Overrides
    //

    /// Called when this controller's view is loaded.
    override func viewDidLoad() {
        super.viewDidLoad();

        oldValue = Int(stepper.value)
        createBlocks(1);
        session.setupSession(&audioIO);
        audioIO.createAudioGraph();
        audioIO.configureAudioGraph();
        audioIO.startAudioGraph();

        player = LiveAudioPlayer(graph: audioIO, session: session);
        makeActions();
    }

    /// Called when the app consumes too much memory.
    /// Dispose of any resources that can be recreated.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /// MARK: UI action responders
    //

    @IBAction func addAndRemoveBlocks(sender: UIStepper) {
        print(Int(sender.value).description, terminator: "")
        if (Int(Int(sender.value).description) > oldValue){
            oldValue = oldValue + 1;
            blockArrays.addBlocks(1);
            updateScrollViewConstraints();
        }

        else {
            oldValue = oldValue - 1;
            blockArrays.removeBlocks(1);
            updateScrollViewConstraints();
        }
    }

    /// Called when the UI's `Stop` button is pressed.
    /// Displays *stop*
    ///
    /// - parameter sender:  The object sending the event.
    @IBAction func StopButtonTouched(sender: AnyObject) {
        print("stop");
    }

    /// Called when the UI's `Play` button is pressed.
    /// Displays *play*
    ///
    /// - parameter sender:  The object sending the event.
    @IBAction func PlayButtonTouched(sender: AnyObject) {
        _ = sender as! UIButton;

        if (player.playing) {
            print("pause");

            player.pause();
        }
        else {
            print("play");
            if let p = player as? LiveAudioPlayer {
                p.audioData = blockArrays.getCleanedList();
                p.play();
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if (segue.identifier == "instrumentsSegue") {
            let sidebar = segue.destinationViewController as! InstrumentsTableViewController;
            sidebar.graph = audioIO;
        }
        else if (segue.identifier == "creationListSegue") {
            print("segueseguesegue")
            let creationList = segue.destinationViewController as! CreationsListVC;
            creationList.mainVC = self;
        }
    }

    /// MARK: Utility methods
    //

    /// Creates a track for each entry in `instrumentsList` with `columns` number of columns.
    /// Each track is added to `dictBlocks` with the corresponding instrument as key.
    /// Each track is added as a subview to `scrollBlocks` and updates the scroll view's size.
    ///
    /// - parameter columns:  The number of columns to add to each track.
    func createBlocks(columns: Int) {

        for (idx, _) in instrumentsList.enumerate() {

            let track: UITimeBlockArray = UITimeBlockArray(rowNbr: idx, noteValue: 60 - idx, inView: scrollBlocks, withGraph: audioIO);

            blockArrays.blockArrays.append(track);
            track.addButtons(columns, color: UIColor.blueColor());
        }
        blockArrays.updateProperties();
        updateScrollViewConstraints();
    }

    func updateScrollViewConstraints() {

        scrollBlocks.contentSize = CGSizeMake(
            CGFloat(blockArrays.endPos.x),
            CGFloat(blockArrays.endPos.y)
        );
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

    func makeActions() {
        importAction = { (alert: UIAlertAction!) -> Void in

            print("File imported")
            self.performSegueWithIdentifier("creationListSegue", sender: self);
        };

        saveAction = { (alert: UIAlertAction!) -> Void in

            print("File Saved")
            let notes = self.blockArrays.getFormattedNoteList();
            let tracks: [String : Any]? = [kOrpheeFileContent_tracks : [0 : notes]];

            let fm = MIDIFileManager(name: "test\(self.fileNbr).mid");
            fm.createFile()
            fm.writeToFile(content: tracks, dataBuilderType: CoreMIDISequenceCreator.self);
            ++self.fileNbr;
        };

        cancelAction = { (alert: UIAlertAction!) -> Void in

            print("Cancelled")
        };
    }

    func importFile(file: String) {
        self.blockArrays.resetBlocks();
        let data: [String : AnyObject] = MIDIFileManager(name: file).readFile()!;
        for (key, value) in data {
            if let tracks = value as? [Int : [[Int]]]
                where key == kOrpheeFileContent_tracks {
                    for (_, track) in tracks {
                        self.blockArrays.updateProperties();
                        let missingBlocks = track.count - self.blockArrays.blockLength;
                        if (missingBlocks > 0) {
                            self.blockArrays.addBlocks(missingBlocks + 1);
                            self.oldValue += missingBlocks + 1;
                            self.stepper.value = Double(self.oldValue);
                        }
                        self.blockArrays.setBlocksFromList(track);
                    }
            }
        }
        self.updateScrollViewConstraints();
    }
}

