//
//  TempoVC.swift
//  Orphee
//
//  Created by John Bobington on 18/12/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import Foundation

import FileManagement

class TempoViewController: UITableViewController {

    var TempoList: [UInt] = []

    weak var mainVC: ViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        for tempo: UInt in 20...480 {
            TempoList.append(tempo)
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TempoList.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        cell.textLabel?.text = "\(TempoList[indexPath.row])"
        return cell;
    }

    /// TODO: Clean it! Possible solution: pFormattedFileManager realisation for SoundBanks/SoundFonts.
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        mainVC.tempoInfo = TempoList[indexPath.row]
    }
}
