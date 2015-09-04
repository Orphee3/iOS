////
////  SidebarVC.swift
////  Orphee
////
////  Created by JohnBob on 04/03/2015.
////  Copyright (c) 2015 __ORPHEE__. All rights reserved.
////
//
//import UIKit
//import FileManagement
//
///// The ViewController in charge of the composition screen's sidebar
//class SidebarVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
//
//    /// The view containing the sidebar's PickerView.
//    @IBOutlet weak var viewForPicker: UIView!
//
//    /// The sidebar's `Save` button.
//    @IBOutlet weak var saveB: UIButton!
//
//    /// The sidebar's `Import` button.
//    @IBOutlet weak var importB: UIButton!
//
//    /// The sidebar's `Instruments` button.
//    @IBOutlet weak var instrumentsB: UIButton!
//
//    /// The sidebar's PickerView.
//    @IBOutlet weak var pickerInstruments: UIPickerView!
//
//    var presetMgr: PresetMgr = PresetMgr();
//    weak var graph: AudioGraph? = nil;
//    weak var blockArrays: BlockArrayList?;
//    weak var scrollView: UIScrollView?;
//
//    /// A list of all instruments supported by the app. TODO: actually implement the system.
//    var instrumentsList: [(name: String, path: String)] = [];
//
//    /// The index of the selected instrument. Updates the `Instruments` button displayed text when set.
//    var currentInstrument: Int = 0 {
//        didSet {
//            instrumentsB.setTitle(instrumentsList[currentInstrument].name, forState: UIControlState.Normal);
//            var instrumentToLoad = presetMgr.getMelodicInstrumentFromSoundBank(path: instrumentsList[currentInstrument].path);
//            graph!.loadInstrumentFromInstrumentData(&instrumentToLoad!);
//        }
//    }
//
//    /// MARK: Overrides
//    //
//
//    /// Called when this controller's view is loaded.
//    override func viewDidLoad() {
//
//        super.viewDidLoad();
//
//        instrumentsList = [("violin", NSBundle.mainBundle().pathForResource("SoundBanks/ProTrax_Classical_Guitar", ofType: "sf2")!),
//            ("guitar", NSBundle.mainBundle().pathForResource("SoundBanks/ProTrax_Classical_Guitar", ofType: "sf2")!),
//            ("tambour", NSBundle.mainBundle().pathForResource("SoundBanks/ProTrax_Classical_Guitar", ofType: "sf2")!),
//            ("battery", NSBundle.mainBundle().pathForResource("SoundBanks/ProTrax_Classical_Guitar", ofType: "sf2")!),
//            ("trumpet", NSBundle.mainBundle().pathForResource("SoundBanks/ProTrax_Classical_Guitar", ofType: "sf2")!)];
//        layoutButtons();
//    }
//
//    /// Called when this controller's view is displayed.
//    override func viewDidAppear(animated: Bool) {
//
//        super.viewDidAppear(animated);
//
//        println("view appears");
//    }
//
//    /// Called when the app consumes too much memory.
//    /// Dispose of any resources that can be recreated.
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//
//    }
//
//    /// MARK: UIPickerViewDataSource protocol
//    //
//
//    /// Called by the picker view when it needs the number of components.
//    ///
//    /// :param: pickerView  An object representing the picker view requesting the data.
//    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
//        return 1;
//    }
//
//    /// Called by the picker view when it needs the number of rows for a specified component.
//    ///
//    /// :param: pickerView  An object representing the picker view requesting the data.
//    /// :param: component   A zero-indexed number identifying a component of pickerView.
//    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return instrumentsList.count;
//    }
//
//    /// MARK: UIPickerViewDelegate protocol
//    //
//
//    /// Called by the picker view when it needs the title to use for a given row in a given component.
//    ///
//    /// :param: pickerView  An object representing the picker view requesting the data.
//    /// :param: row         A zero-indexed number identifying a row of component.
//    /// :param: component   A zero-indexed number identifying a component of pickerView.
//    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
//        return instrumentsList[row].name;
//    }
//
//    /// Called by the picker view when the user selects a row in a component.
//    ///
//    /// :param: pickerView  An object representing the picker view requesting the data.
//    /// :param: row         A zero-indexed number identifying a row of component.
//    /// :param: component   A zero-indexed number identifying a component of pickerView.
//    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//
//        currentInstrument = row;
//        println("chosen instrument : \(instrumentsList[row])");
//    }
//
//    /// MARK: UI action responders
//    //
//
//    /// Called when the UI's `Save` button is pressed.
//    /// Displays *save*
//    ///
//    /// :param: sender  The object sending the event.
//    @IBAction func saveButtonTouched(sender: AnyObject) {
//        println("save");
//        var notes = blockArrays?.getFormattedNoteList();
//        var tracks: [String : AnyObject] = ["TRACKS" : [0 : notes!]];
//
//        MIDIFileManager(name: "test").createFile(nil, content: tracks);
//    }
//
//    /// Called when the UI's `Import` button is pressed.
//    /// Displays *import*
//    ///
//    /// :param: sender  The object sending the event.
//    @IBAction func importButtonTouched(sender: AnyObject) {
//        println("import");
//
//        blockArrays.resetBlocks();
//        var data: [String : AnyObject] = MIDIFileManager(name: "test").readFile(nil)!;
//        for (key, value) in data {
//            if (key == "TRACKS") {
//                if let tracks = value as? [Int : [[Int]]] {
//                    blockArrays.updateProperties();
//                    var missingBlocks = tracks[0]!.count - blockArrays.blockLength;
//                    if (missingBlocks >= 0) {
//                        blockArrays.addBlocks(missingBlocks + 1);
//                    }
//                    blockArrays.setBlocksFromList(tracks[0]!);
//                }
//            }
//        }
//        scrollView!.contentSize = CGSizeMake(CGFloat(blockArrays!.endPos.x), CGFloat(blockArrays!.endPos.y));
//    }
//
//    /// Called when the PickerView's `Close` button is pressed.
//    /// Closes the PickerView.
//    ///
//    /// :param: sender  The object sending the event.
//    @IBAction func closeViewForPicker(sender: AnyObject) {
//
//        viewForPicker.hidden = true;
//    }
//
//    /// Called when the UI's `Instruments` button is pressed.
//    /// Reveals the PickerView.
//    ///
//    /// :param: sender  The object sending the event.
//    @IBAction func instrumentsButtonTouched(sender: AnyObject) {
//
//        viewForPicker.hidden = false;
//        currentInstrument = Int(currentInstrument);
//    }
//
//    /// MARK: Utility methods
//    //
//
//    /// Defines the controlled buttons' appearance.
//    func layoutButtons() {
//
//        saveB.layer.cornerRadius = 8;
//        saveB.layer.borderWidth = 1;
//        importB.layer.cornerRadius = 8;
//        importB.layer.borderWidth = 1;
//        instrumentsB.layer.cornerRadius = 8;
//        instrumentsB.layer.borderWidth = 1;
//    }
//}
