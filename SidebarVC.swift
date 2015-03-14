//
//  SidebarVC.swift
//  Orphee
//
//  Created by JohnBob on 04/03/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit

class SidebarVC: UIViewController, UIPickerViewDelegate {

    @IBOutlet weak var viewForPicker: UIView!
    @IBOutlet weak var saveB: UIButton!
    @IBOutlet weak var importB: UIButton!
    @IBOutlet weak var instrumentsB: UIButton!
    @IBOutlet weak var pickerInstruments: UIPickerView!

    var instrumentsList: [String] = [];
    var currentInstrument: Int = 0 {
        didSet {
            instrumentsB.setTitle(instrumentsList[currentInstrument], forState: UIControlState.Normal);
        }
    }

    override func viewDidLoad() {

        super.viewDidLoad();

        instrumentsList = ["violin", "guitar", "tambour", "battery", "trumpet"];
        layoutButtons();
        pickerInstruments.dataSource;
    }

    override func viewDidAppear(animated: Bool) {

        super.viewDidAppear(animated);

        println("view appears");
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func layoutButtons() {

        saveB.layer.cornerRadius = 8;
        saveB.layer.borderWidth = 1;
        importB.layer.cornerRadius = 8;
        importB.layer.borderWidth = 1;
        instrumentsB.layer.cornerRadius = 8;
        instrumentsB.layer.borderWidth = 1;
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return instrumentsList[row];
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        currentInstrument = row;
        println("chosen instrument : \(instrumentsList[row])");
    }

    @IBAction func saveButtonTouched(sender: AnyObject) {
        println("save");
    }

    @IBAction func importButtonTouched(sender: AnyObject) {
        println("import");
    }

    @IBAction func closeViewForPicker(sender: AnyObject) {

        viewForPicker.hidden = true;
    }

    @IBAction func instrumentsButtonTouched(sender: AnyObject) {

        viewForPicker.hidden = false;
        currentInstrument = Int(currentInstrument);
    }
}