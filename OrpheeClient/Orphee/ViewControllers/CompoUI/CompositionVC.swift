//
//  CompositionVC.swift
//  CompoUI
//
//  Created by John Bobington on 22/01/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import UIKit
import MIDIToolbox
import FileManagement

class CompositionVC: UIViewController, UINavigationControllerDelegate, pCreationListActor {

    typealias AlertAction = ((UIAlertAction!) -> Void)

    /// The scroll view containing the composition area
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var trackBar: UIToolbar!
    @IBOutlet weak var addButton: UIButton!

    @IBOutlet weak var panSide: UIPanGestureRecognizer!

    @IBOutlet weak var dataMgr: DataMgr!
    @IBOutlet weak var gridOps: compoGridOpsIntent!
    @IBOutlet weak var dataSrc: compoGridDataSource!

    @IBOutlet weak var trackBarOps: trackBarOpsIntent!

    @IBOutlet weak var currentInstrument: UIBarButtonItem!
    @IBOutlet weak var bpm: UIBarButtonItem!

    var tracks = [DataMgr]()
    var tracksInfo: [[String : Any]?] = [[eOrpheeFileContent.PatchID.rawValue : 1]]
    var tempoInfo: UInt = 120 {
        willSet {
            self.bpm.title = "@\(newValue)Bpm"
        }
    }

    var commonOffset: CGFloat = 0
    var currentTrack: Int = 0
    var trkCount: Int = 0

    var fileForSegue: String?
    var fileNbr: Int = 0;

    var mutedTracks: Set<Int> = []

    var player: MIDIPlayer?;
    var audioIO: AudioGraph = AudioGraph();
    var session: AudioSession = AudioSession();

    var tempoAction: AlertAction!
    var importAction: AlertAction!
    var saveAction: AlertAction!
    var cancelAction: AlertAction!

    var content: [String : Any] {
        get {
            return [
                eOrpheeFileContent.Tracks.rawValue : self.prepareTracksForSave(),
                eOrpheeFileContent.TracksInfos.rawValue : self.tracksInfo,
                eOrpheeFileContent.Tempo.rawValue : self.tempoInfo
            ]
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let mgr = DataMgr()
        self.dataMgr.data = mgr.data
        self.tracks.append(mgr)
        self.setupAudio()
        self.setupGraphics()
        self.makeActions();
//        panSide.requireGestureRecognizerToFail(self.tableView.panGestureRecognizer)
        if let segueFile = fileForSegue {
            self.importFile(segueFile)
        }

        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: dataMgr.lineIdxForNote(60), inSection: 0), atScrollPosition: .Top, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.dataMgr.resetData()
        self.tracks.removeAll()
        self.tableView.reloadData()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBarHidden = true
        self.tableView.reloadData()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        navigationController?.navigationBarHidden = false
        if (segue.identifier == "instrumentsSegue") {
            let instrus = segue.destinationViewController as! InstrumentsTableViewController;
            instrus.mainVC = self;
        }
        else if (segue.identifier == "creationListSegue") {
            let creationList = segue.destinationViewController as! CreationsListVC;
            creationList.mainVC = self;
        }
        else if (segue.identifier == "tempoSegue") {
            let tempoVC = segue.destinationViewController as! TempoViewController;
            tempoVC.mainVC = self;
        }
    }

    func setupAudio() {
        self.session.setupSession(&audioIO);
        self.audioIO.createAudioGraph();
        self.audioIO.configureAudioGraph();
        self.audioIO.startAudioGraph();
    }

    func setupGraphics() {
        self.tableView.rowHeight = 40
        self.tableView.separatorStyle = .None
        self.currentInstrument.title = "Grand piano"
        self.currentInstrument.enabled = false
        self.tempoInfo = 120
        self.bpm.enabled = false
        self.addButton.layer.borderWidth = 2
        self.addButton.layer.borderColor = UIColor.lightGrayColor().CGColor
    }

    func prepareTracksForSave() -> [Int : TimedMidiMsgCollection] {
        var trks = [Int : TimedMidiMsgCollection]()
        for (idx, trackMgr) in tracks.enumerate() {
            if self.mutedTracks.contains(idx) { continue }
            let timedMidiMsgCollections = trackMgr.dataAsTimedMidiMsgsCollection()
            timedMidiMsgCollections.forEach() { _, msgCollection in
                for var midiMsg in msgCollection {
                    midiMsg.channel = UInt8(idx)
                }
            }
            trks[idx] = timedMidiMsgCollections
        }
        return trks
    }

    func saveFile() {
        let tracks: [String : Any]? = [
            eOrpheeFileContent.Tracks.rawValue : self.prepareTracksForSave(),
            eOrpheeFileContent.TracksInfos.rawValue : self.tracksInfo,
            eOrpheeFileContent.Tempo.rawValue : self.tempoInfo
        ];
        let fm = MIDIFileManager(name: "test\(self.fileNbr).mid");
        fm.createFile()
        precondition(fm.writeToFile(content: tracks, dataBuilderType: CoreMIDISequenceCreator.self));
        //        if OrpheeReachability().isConnected() {
        //            OrpheeApi().sendCreationToServer(eCreationRouter.userID!, name: fm.name, completion: { print($0) });
        //        }
        let _ = try? NSFileManager.defaultManager().copyItemAtPath(fm.path, toPath: "/Users/johnbob/Desktop/\(fm.name)");

        fileNbr += 1
    }

    func importFile(file: String) {
        if let data = MIDIFileManager(name: file).readFile() {
            self.tempoInfo = 0
            self.tracksInfo.removeAll()
            self.tracks.removeAll()
            if let tempo = data[eOrpheeFileContent.Tempo.rawValue] as? UInt {
                self.tempoInfo = tempo
            }
            if let infos = data[eOrpheeFileContent.TracksInfos.rawValue] as? [[String : Any]?] {
                self.tracksInfo = infos
            }
            if let tracks = data[eOrpheeFileContent.Tracks.rawValue] as? [Int : TimedMidiMsgCollection] {
                tracks.sort { $0.0.0 < $0.1.0 }.forEach { (_, collection) in
                    if collection.count > 0 {
                        self.tracks.append(DataMgr(timedMsgCollection: collection))
                    }
                }
                if let newData = self.tracks.first?.data {
                    self.dataMgr.data = newData
                }
                else {
                    let newData = DataMgr()
                    self.tracks.append(newData)
                    self.dataMgr.data = newData.data
                }
            }
        }
    }

    func actOnSelectedCreation(creation: String) {

        fileForSegue = creation
        importFile(fileForSegue ?? "test")
        self.tableView.reloadData()
        self.trackBarOps.refresh()
}

    func cleanData() {
        self.tracks.removeAll()
        self.tracksInfo.removeAll()
        self.currentTrack = 0

        let mgr = DataMgr()
        self.tracksInfo.append([eOrpheeFileContent.PatchID.rawValue : 1])
        self.tracks.append(mgr)
        self.dataMgr.data = mgr.data
        self.tableView.reloadData()
        self.trackBarOps.refresh()
    }

    func addTrack() {
        self.tracks.append(DataMgr())
        self.tracksInfo.append([eOrpheeFileContent.PatchID.rawValue : 1])
        self.changeCurrentTrack(self.tracks.count - 1)
    }

    func removeTrack(idx: Int) {
        guard idx >= 0 && idx < self.tracks.count else { return }
        if self.tracks.count == 1 {
            self.cleanData()
            return
        }
        self.tracks.removeAtIndex(idx)
        switch idx {
        case _ where idx == self.currentTrack:
            self.changeCurrentTrack(0)
        case _ where idx < self.currentTrack:
            self.currentTrack -= 1
        default:
            break
        }
    }

    func toggleMute(forTrack: Int) {
        if let idx = mutedTracks.indexOf(forTrack) {
            mutedTracks.removeAtIndex(idx)
        } else {
            mutedTracks.insert(forTrack)
        }
    }

    func changeCurrentTrack(idx: Int) {
        guard idx >= 0 && idx < self.tracks.count else { return }
        self.currentTrack = idx
        self.tableView.reloadData()
        self.trackBarOps.refresh()
    }

    func makeActions() {
        tempoAction = { AlertAction in

            print("Change tempo")
            self.performSegueWithIdentifier("tempoSegue", sender: self);
        };

        importAction = { AlertAction in

            print("Importe File")
            self.performSegueWithIdentifier("creationListSegue", sender: self);
        };

        saveAction = { AlertAction in

            print("File Saved")
            self.saveFile()
        };

        cancelAction = { AlertAction in

            print("Cancelled")
        };
    }

    func presentActions() {
        let optionMenu = UIAlertController(title: nil, message: "Choisissez une option", preferredStyle: .ActionSheet)

        let importAction = UIAlertAction(title: "Importer", style: .Default, handler: self.importAction);
        let tempoAction = UIAlertAction(title: "Choisir le tempo", style: .Default, handler: self.tempoAction);
        let saveAction = UIAlertAction(title: "Sauvegarder", style: .Default, handler: self.saveAction)
        let cancelAction = UIAlertAction(title: "Annuler", style: .Cancel, handler: self.cancelAction)
        
        optionMenu.addAction(tempoAction)
        optionMenu.addAction(importAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
}
