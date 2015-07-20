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

    var oldValue: Int!

    var importAction: ((UIAlertAction!) -> Void)!
    var saveAction: ((UIAlertAction!) -> Void)!
    var cancelAction: ((UIAlertAction!) -> Void)!


    /// MARK: Overrides
    //

    /// Called when this controller's view is loaded.
    override func viewDidLoad() {
        super.viewDidLoad();

        oldValue = Int(stepper.value).description.toInt()
        createBlocks(1);
        session.setupSession(&audioIO);
        audioIO.createAudioGraph();
        audioIO.configureAudioGraph();
        audioIO.startAudioGraph();

        player = GenericPlayer(graph: audioIO, session: session);
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
        println(Int(sender.value).description)
        if (Int(sender.value).description.toInt() > oldValue){
            oldValue = oldValue! + 1;
            blockArrays.addBlocks(1);
            updateScrollViewConstraints();
        }

        else {
            oldValue = oldValue! - 1;
            blockArrays.removeBlocks(1);
            updateScrollViewConstraints();
        }
    }

    /// Called when the UI's `Stop` button is pressed.
    /// Displays *stop*
    ///
    /// :param: sender  The object sending the event.
    @IBAction func StopButtonTouched(sender: AnyObject) {
        println("stop");
    }

    /// Called when the UI's `Play` button is pressed.
    /// Displays *play*
    ///
    /// :param: sender  The object sending the event.
    @IBAction func PlayButtonTouched(sender: AnyObject) {
        var button = sender as! UIButton;

        if (player.isPlaying()) {
            println("stop");

            player.stop();
        }
        else {
            println("play");

            saveAction(UIAlertAction());
            importAction(UIAlertAction());
            player.play();
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if (segue.identifier == "instrumentsSegue") {
            var sidebar = segue.destinationViewController as! InstrumentsTableViewController;
            sidebar.graph = audioIO;
        }
    }

    /// MARK: Utility methods
    //

    /// Creates a track for each entry in `instrumentsList` with `columns` number of columns.
    /// Each track is added to `dictBlocks` with the corresponding instrument as key.
    /// Each track is added as a subview to `scrollBlocks` and updates the scroll view's size.
    ///
    /// :param: columns  The number of columns to add to each track.
    func createBlocks(columns: Int) {

        for (idx, instrument) in enumerate(instrumentsList) {

            var track: UITimeBlockArray = UITimeBlockArray(rowNbr: idx, noteValue: 60 - idx, inView: scrollBlocks, withGraph: audioIO);

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

            println("File imported")
            self.blockArrays.resetBlocks();
            var data: [String : AnyObject] = MIDIFileManager(name: "test").readFile(nil)!;
            for (key, value) in data {
                if (key == "TRACKS") {
                    if let tracks = value as? [Int : [[Int]]] {
                        self.blockArrays.updateProperties();
                        var missingBlocks = tracks[0]!.count - self.blockArrays.blockLength;
                        if (missingBlocks > 0) {
                            self.blockArrays.addBlocks(missingBlocks + 1);
                            self.oldValue! += missingBlocks + 1;
                            self.stepper.value = Double(self.oldValue!);
                        }
                        self.blockArrays.setBlocksFromList(tracks[0]!);
                    }
                }
            }
            self.updateScrollViewConstraints();
        };

        saveAction = { (alert: UIAlertAction!) -> Void in

            println("File Saved")
            var notes = self.blockArrays.getFormattedNoteList();
            var tracks: [String : AnyObject] = ["TRACKS" : [0 : notes]];

            MIDIFileManager(name: "test").createFile(nil, content: tracks);
        };

        cancelAction = { (alert: UIAlertAction!) -> Void in

            println("Cancelled")
        };
    }
}

