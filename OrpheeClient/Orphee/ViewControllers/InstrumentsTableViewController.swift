//
//  InstrumentsTableViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 27/06/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit

class InstrumentsTableViewController: UITableViewController {

    var instrumentsList: [(name: String, path: String)] = [];

    var presetMgr: PresetMgr = PresetMgr();
    weak var graph: AudioGraph? = nil;

    override func viewDidLoad() {
        super.viewDidLoad()

        instrumentsList = [("Yamaha Grand Piano", "32MbGMStereo"),
            ("Bight Yamaha Grand Piano", "32MbGMStereo"),
            ("Electric Piano", "32MbGMStereo"),
            ("Honky Tonk", "32MbGMStereo"),
            ("Rhodes EP", "32MbGMStereo"),
            ("Legend EP2", "32MbGMStereo"),
            ("Harpsichord", "32MbGMStereo"),
            ("Clavinet", "32MbGMStereo"),
            ("Celesta", "32MbGMStereo"),
            ("Glockenspiel", "32MbGMStereo"),
            ("Music Box", "32MbGMStereo"),
            ("Vibraphone", "32MbGMStereo"),
            ("Marimba", "32MbGMStereo"),
            ("Xylophone", "32MbGMStereo")
        ];
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return instrumentsList.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        cell.textLabel?.text = instrumentsList[indexPath.row].name;
        return cell;
    }

    /// TODO: Clean it! Possible solution: pFormattedFileManager realisation for SoundBanks/SoundFonts.
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        var instrumentToLoad = presetMgr.getMelodicInstrumentFromSoundBank(UInt8(indexPath.row),
            path: NSBundle.mainBundle().pathForResource("SoundBanks/" + instrumentsList[indexPath.row].path, ofType: "sf2")!);
        graph!.loadInstrumentFromInstrumentData(&instrumentToLoad!);
    }
}
