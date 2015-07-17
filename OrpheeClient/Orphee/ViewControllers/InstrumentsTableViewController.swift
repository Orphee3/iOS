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

        instrumentsList = [("violin", NSBundle.mainBundle().pathForResource("SoundBanks/ProTrax_Classical_Guitar", ofType: "sf2")!),
            ("guitar", NSBundle.mainBundle().pathForResource("SoundBanks/ProTrax_Classical_Guitar", ofType: "sf2")!),
            ("tambour", NSBundle.mainBundle().pathForResource("SoundBanks/ProTrax_Classical_Guitar", ofType: "sf2")!),
            ("battery", NSBundle.mainBundle().pathForResource("SoundBanks/ProTrax_Classical_Guitar", ofType: "sf2")!),
            ("trumpet", NSBundle.mainBundle().pathForResource("SoundBanks/ProTrax_Classical_Guitar", ofType: "sf2")!)];
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

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        var instrumentToLoad = presetMgr.getMelodicInstrumentFromSoundBank(path: instrumentsList[indexPath.row].path);
        graph!.loadInstrumentFromInstrumentData(&instrumentToLoad!);
    }
}