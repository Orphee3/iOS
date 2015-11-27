//
//  InstrumentsTableViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 27/06/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit
import FileManagement

class InstrumentsTableViewController: UITableViewController {

    var instrumentsList: [String] = [];

    var presetMgr: PresetMgr = PresetMgr();
    weak var mainVC: ViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        instrumentsList = [
            "Grand piano acoustique",
            "Piano acoustique",
            "Grand piano électrique",
            "Piano bastringue",
            "Rhodes",
            "Piano avec effet chorus",
            "Clavecin",
            "Clavinet",
            "Célesta",
            "Glockenspiel",
            "Boîte à musique",
            "Vibraphone",
            "Marimba",
            "Xylophone",
            "Cloches tubulaires",
            "Dulcimer",
            "Orgue Hammond",
            "Orgue percussif",
            "Orgue rock",
            "Orgue d'église",
            "Harmonium",
            "Accordéon",
            "Harmonica",
            "Bandonéon",
            "Guitare classique",
            "Guitare folk",
            "Guitare électrique - Jazz",
            "Guitare électrique - son clair",
            "Guitare électrique - sourdine",
            "Guitare avec overdrive",
            "Guitare avec distorsion",
            "Harmoniques de guitare",
            "Basse acoustique sans frettes",
            "Basse électrique jouée au doigt",
            "Basse électrique jouée au médiator",
            "Basse sans frettes",
            "Basse slapée 1",
            "Basse slapée 2",
            "Synthétiseur basse 1",
            "Synthétiseur basse 2",
            "Violon",
            "Violon alto",
            "Violoncelle",
            "Contrebasse",
            "Cordes en trémolo",
            "Cordes en pizzicato",
            "Harpe",
            "Timbales",
            "Ensemble acoustique à Cordes 1",
            "Ensemble acoustique à Cordes 2",
            "Synthétiseur de cordes 1",
            "Synthétiseur de cordes 2",
            "Chœur - Aah",
            "Chœur - Ooh",
            "Voix synthétique",
            "Coup d'orchestre",
            "trompette",
            "Trombone",
            "Tuba",
            "trompette en sourdine",
            "Cor d'harmonie (French horn)",
            "Section de cuivres",
            "Synthétiseur de Cuivres 1",
            "Synthétiseur de Cuivres 2",
            "Saxophone soprano",
            "Saxophone alto",
            "Saxophone ténor",
            "Saxophone baryton",
            "Hautbois",
            "Cor anglais",
            "Basson",
            "Clarinette",
            "Piccolo",
            "Flûte",
            "Flûte à bec",
            "Flûte de pan",
            "Bouteille soufflée",
            "Shakuhachi",
            "Sifflet",
            "Ocarina",
            "Signal carré (Lead 1 (square))",
            "Signal en dents de scie (Lead 2 (sawtooth))",
            "Orgue à vapeur (Lead 3 (calliope lead))",
            "Chiffer (Lead 4 (chiff lead))",
            "Charang (Lead 5 (charang))",
            "Voix solo (Lead 6 (voice))",
            "Signal en dents de scie en quinte (Lead 7 (fifths))",
            "Basse & Solo (Lead 8 (bass + lead))",
            "Fantaisie (Pad 1 (new age))",
            "Son chaleureux (Pad 2 (warm))",
            "Polysynthé (Pad 3 (polysynth))",
            "Chœur (Pad 4 (choir))",
            "Archet (Pad 5 (bowed))",
            "Son métallique (Pad 6 (metallic))",
            "Halo (Pad 7 (halo))",
            "Balai (Pad 8 (sweep))",
            "Pluie de glace",
            "Trames sonores",
            "Cristal",
            "Atmosphère",
            "Brillance",
            "Gobelins (Goblins)",
            "Échos",
            "Espace (Sci-Fi)",
            "Sitar",
            "Banjo",
            "Shamisen",
            "Koto",
            "Kalimba",
            "Cornemuse",
            "Viole",
            "Shehnai",
            "Clochettes",
            "Agogo",
            "Batterie métallique",
            "Planchettes",
            "Timbales",
            "Tom mélodique",
            "Tambour synthétique",
            "Cymbale inversée",
            "Guitare - bruit de frette",
            "Respiration",
            "Rivage",
            "Gazouillis",
            "Sonnerie de téléphone",
            "Hélicoptère",
            "Applaudissements",
            "Coup de feu"
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
        cell.textLabel?.text = instrumentsList[indexPath.row]
        return cell;
    }

    /// TODO: Clean it! Possible solution: pFormattedFileManager realisation for SoundBanks/SoundFonts.
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        var instrumentToLoad = presetMgr.getMelodicInstrumentFromSoundBank(UInt8(indexPath.row),
            path: NSBundle.mainBundle().pathForResource("SoundBanks/32MbGMStereo" , ofType: "sf2")!);
        if var trackInfo = mainVC.tracksInfo[mainVC.currentTrack] {
            trackInfo[eOrpheeFileContent.PatchID.rawValue] = indexPath.row;
            mainVC.tracksInfo[mainVC.currentTrack] = trackInfo
        }
        else {
            mainVC.tracksInfo[mainVC.currentTrack] = [eOrpheeFileContent.PatchID.rawValue : indexPath.row]
        }
        mainVC.audioIO.loadInstrumentFromInstrumentData(&instrumentToLoad!);
    }
}
