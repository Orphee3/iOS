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

        oldValue = Int(stepper.value.description)
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
        print(Int(sender.value).description, terminator: "")
        if (Int(Int(sender.value).description) > oldValue){
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
    /// - parameter sender:  The object sending the event.
    @IBAction func StopButtonTouched(sender: AnyObject) {
        print("stop", terminator: "")
    }

    /// Called when the UI's `Play` button is pressed.
    /// Displays *play*
    ///
    /// - parameter sender:  The object sending the event.
    @IBAction func PlayButtonTouched(sender: AnyObject) {
        _ = sender as! UIButton;

        if (player.isPlaying()) {
            print("stop", terminator: "");

            player.stop();
        }
        else {
            print("play", terminator: "");

            saveAction(UIAlertAction());
            importAction(UIAlertAction());

            // Download/load a MIDI file as NSData
            let url = NSURL(string: "https://s3-eu-west-1.amazonaws.com/orphee/audio/14418797388120.49655897286720574")!
            let data = NSData(contentsOfURL: url)
            player.play(data!);
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if (segue.identifier == "instrumentsSegue") {
            let sidebar = segue.destinationViewController as! InstrumentsTableViewController;
            sidebar.graph = audioIO;
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

            print("File imported", terminator: "")
            self.blockArrays.resetBlocks();
            let data: [String : AnyObject] = MIDIFileManager(name: "test").readFile(nil)!;
            for (key, value) in data {
                if (key == "TRACKS") {
                    if let tracks = value as? [Int : [[Int]]] {
                        self.blockArrays.updateProperties();
                        let missingBlocks = tracks[0]!.count - self.blockArrays.blockLength;
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

            print("File Saved", terminator: "")
            let notes = self.blockArrays.getFormattedNoteList();
            let tracks: [String : AnyObject] = ["TRACKS" : [0 : notes]];
            
            MIDIFileManager(name: "test").createFile(nil, content: tracks);
        };
        
        cancelAction = { (alert: UIAlertAction!) -> Void in
            
            print("Cancelled", terminator: "")
        };
    }
}

