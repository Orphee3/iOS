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

    var tracks = [DataMgr]()
    var tracksInfo: [[String : Any]?] = [[eOrpheeFileContent.TracksInfos.rawValue : [eOrpheeFileContent.PatchID : 1]]]
    var tempoInfo: UInt = 120

    var commonTime: Int = 0
    var currentTrack: Int = 0
    var trkCount: Int = 0

    var fileForSegue: String?
    var fileNbr: Int = 0;


    var player: MIDIPlayer?;
    var audioIO: AudioGraph = AudioGraph();
    var session: AudioSession = AudioSession();

    var tempoAction: AlertAction!
    var importAction: AlertAction!
    var saveAction: AlertAction!
    var cancelAction: AlertAction!

//    let supportedOrientations: UIInterfaceOrientationMask = [.Landscape]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.dataMgr.data = DataMgr().data
        self.tracks.append(self.dataMgr)
        self.trackBarOps.setup()
        self.setupAudio()
        self.setupGraphics()
        self.makeActions();

        if let segueFile = fileForSegue {
            self.importFile(segueFile)
        }

        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: dataMgr.lineIdxForNote(60), inSection: 0), atScrollPosition: .Top, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
            print("segueseguesegue")
            let creationList = segue.destinationViewController as! CreationsListVC;
            creationList.mainVC = self;
        }
        else if (segue.identifier == "tempoSegue") {
            print("segueseguesegue")
            let tempoVC = segue.destinationViewController as! TempoViewController;
            tempoVC.mainVC = self;
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.trackBarOps.updateLayout()
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
        self.currentInstrument.title = "Guitare"
        self.currentInstrument.enabled = false
        self.addButton.layer.borderWidth = 2
        self.addButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.tableView.backgroundColor = UIColor.whiteColor()
    }

    func prepareTracksForSave() -> [Int : TimedMidiMsgCollection] {
        var trks = [Int : TimedMidiMsgCollection]()
        for (idx, trackMgr) in tracks.enumerate() {
            let timedMidiMsgCollections = trackMgr.dataAsTimedMidiMsgsCollection()
            timedMidiMsgCollections.forEach() { _, msgCollection in
                for var midiMsg in msgCollection {
                    midiMsg.channel = UInt8(idx)
                }
            }
            trks[idx] = timedMidiMsgCollections
        }
        print(trks)
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
        try? NSFileManager.defaultManager().copyItemAtPath(fm.path, toPath: "/Users/johnbob/Desktop/\(fm.name)");

        fileNbr++
    }

    func importFile(file: String) {
        let data: [String : Any] = MIDIFileManager(name: file).readFile()!;
        //        print(data)
        for (key, value) in data {
            if key == eOrpheeFileContent.Tempo.rawValue {
                tempoInfo = value as! UInt
            }
            if var trackList = value as? [Int : [[Int]]]
                where key == eOrpheeFileContent.Tracks.rawValue {
                    currentTrack = 0;
                    for idx in 0..<trackList.count {
                        let track = trackList[idx]!
                    }
                    if let infoList = value as? [[String : Any]]
                        where key == eOrpheeFileContent.TracksInfos.rawValue {
                            for (idx, info) in infoList.enumerate() {
                                if let patch = info[eOrpheeFileContent.PatchID.rawValue] as? Int {
                                    tracksInfo[idx] = [eOrpheeFileContent.PatchID.rawValue : patch];
                                }
                            }
                    }
            }
        }
    }

    func actOnSelectedCreation(creation: String) {

        fileForSegue = creation
    }

    func makeActions() {
        tempoAction = { AlertAction in

            print("Change tempo")
            self.performSegueWithIdentifier("tempoSegue", sender: self);
        };

        importAction = { AlertAction in

            print("File imported")
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
