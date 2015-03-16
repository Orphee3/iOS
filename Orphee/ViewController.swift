//
//  ViewController.swift
//  Orphee
//
//  Created by John Bob on 29/01/15.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit

/// The app's main view controller
class ViewController: UIViewController {

    /// The scroll view containing the composition area
    @IBOutlet weak var scrollBlocks: UIScrollView!

    /// A dictionary with as key, the track name and as value, a corresponding wrapper around a UITrackTimeBlock array.
    var dictBlocks: [String:UITimeBlockArray] = [:];

    /// A list of all instruments supported by the app. TODO: actually implement the system.
    var instrumentsList: [String] = ["violin", "guitar", "tambour", "battery", "trumpet"];

    /// MARK: Overrides
    //

    /// Called when this controller's view is loaded.
    override func viewDidLoad() {
        super.viewDidLoad();

        createBlocks(10);
    }

    /// Called when the app consumes too much memory.
    /// Dispose of any resources that can be recreated.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /// MARK: UI action responders
    //

    /// Called when the UI's `add` button is pressed.
    /// Adds 4 buttons to each track and updates the scroll view's size.
    ///
    /// :param: sender  The object sending the event.
    @IBAction func addColumOfBlocks(sender: AnyObject) {

        for (instrument, track) in dictBlocks {

            track.addButtons(4, color: UIColor.redColor());
            scrollBlocks.contentSize = CGSizeMake(CGFloat(track.endPos.x), CGFloat(track.endPos.y));
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
        println("play");
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

            var track: UITimeBlockArray = UITimeBlockArray(count: columns, rowNbr: idx, color: UIColor.blueColor());

            dictBlocks[instrument] = track;
            scrollBlocks.addSubview(track);
            scrollBlocks.contentSize = CGSizeMake(CGFloat(track.endPos.x), CGFloat(track.endPos.y));
        }
    }
}

