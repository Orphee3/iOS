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

        instrumentsList = [("Yamaha Grand Piano", "FluidR3_GM"),
            ("Bight Yamaha Grand Piano", "FluidR3_GM"),
            ("Electric Piano", "FluidR3_GM"),
            ("Honky Tonk", "FluidR3_GM"),
            ("Rhodes EP", "FluidR3_GM"),
            ("Legend EP2", "FluidR3_GM"),
            ("Harpsichord", "FluidR3_GM"),
            ("Clavinet", "FluidR3_GM"),
            ("Celesta", "FluidR3_GM"),
            ("Glockenspiel", "FluidR3_GM"),
            ("Music Box", "FluidR3_GM"),
            ("Vibraphone", "FluidR3_GM"),
            ("Marimba", "FluidR3_GM"),
            ("Xylophone", "FluidR3_GM")
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
