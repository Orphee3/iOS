//
//  compoGridDataSource.swift
//  CompoUI
//
//  Created by John Bobington on 22/01/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import UIKit
import MDSpreadView
import FileManagement

class compoGridDataSource: NSObject, MDSpreadViewDataSource {

    @IBOutlet weak var VC: CompositionVC!
    @IBOutlet weak var dataMgr: DataMgr!
    var presetMgr: PresetMgr = PresetMgr()
    var graph: AudioGraph = {
        let graph = AudioGraph()
        graph.createAudioGraph()
        graph.configureAudioGraph()
        graph.startAudioGraph()
        return graph
    }()

    let bank = NSBundle.mainBundle().pathForResource("SoundBanks/32MbGMStereo", ofType: "sf2")!
    let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]

    func spreadView(aSpreadView: MDSpreadView!, numberOfRowsInSection section: Int) -> Int {
        return dataMgr.lines
    }

    func spreadView(aSpreadView: MDSpreadView!, numberOfColumnsInSection section: Int) -> Int {
        return dataMgr.cellCountForLine(0)
    }

    func numberOfRowSectionsInSpreadView(aSpreadView: MDSpreadView!) -> Int {
        return 1
    }

    func numberOfColumnSectionsInSpreadView(aSpreadView: MDSpreadView!) -> Int {
        return 1
    }


    func spreadView(aSpreadView: MDSpreadView!, cellForHeaderInColumnSection section: Int, forRowAtIndexPath rowPath: MDIndexPath!) -> MDSpreadViewCell! {
        let cell: MDSpreadViewHeaderCell
        if let cl = aSpreadView.dequeueReusableCellWithIdentifier("header") as? MDSpreadViewHeaderCell {
            cell = cl
        } else {
            cell = MDSpreadViewHeaderCell(style: MDSpreadViewHeaderCellStyleRow, reuseIdentifier: "header")
        }
        let row = self.dataMgr.noteForLine(rowPath.row)
        cell.textLabel.text = notes[row % 12] + " \(row / 12 - 1)"
        return cell
    }

    func spreadView(aSpreadView: MDSpreadView!, cellForRowAtIndexPath rowPath: MDIndexPath!, forColumnAtIndexPath columnPath: MDIndexPath!) -> MDSpreadViewCell! {
        let row = rowPath.row
        let cell: CompoGridCell
        if let cl = aSpreadView.dequeueReusableCellWithIdentifier("content") as? CompoGridCell {
            cell = cl
        } else {
            cell = CompoGridCell(style: MDSpreadViewCellStyleDefault, reuseIdentifier: "content")
        }
        if let dataCell = dataMgr.dataCell(atRow: columnPath.column, forLine: row) {
            cell.active = dataCell.active
        }
        self.setupCellAudioData(cell, noteID: self.dataMgr.noteForLine(row))
        return cell
    }

    func setupCellAudioData(cell: CompoGridCell, noteID: Int) {

        cell.note = noteID
        cell.graph = self.graph
        if let infos = self.VC.tracksInfo[self.VC.currentTrack],
            let id = infos[eOrpheeFileContent.PatchID.rawValue] as? Int,
            var data = self.presetMgr.getMelodicInstrumentFromSoundBank(UInt8(id), path: self.bank, isSoundFont: true) {
            cell.graph?.loadInstrumentFromInstrumentData(&data)
        }
    }
}

class compoGridDelegate: NSObject, MDSpreadViewDelegate {
    @IBOutlet weak var dataMgr: DataMgr!

    func spreadView(aSpreadView: MDSpreadView!, didSelectCellForRowAtIndexPath rowPath: MDIndexPath!, forColumnAtIndexPath columnPath: MDIndexPath!) {
        print("column: ", columnPath.column, "row: ", rowPath.row)

        let row = rowPath.row
        self.dataMgr.activateCell(atRow: columnPath.column, forLine: row)
        aSpreadView.reloadData()
    }
}
