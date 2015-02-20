//
//  ViewController.swift
//  Orphee
//
//  Created by John Bob on 29/01/15.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{

    @IBOutlet weak var viewForPicker: UIView!
    @IBOutlet weak var saveB: UIButton!
    @IBOutlet weak var importB: UIButton!
    @IBOutlet weak var instrumentsB: UIButton!
    @IBOutlet weak var pickerInstruments: UIPickerView!
    @IBOutlet weak var viewForBlocks: UIView!
    var instrumentsList: [String] = [];
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutButtons()
        createBlocks()
        instrumentsList = ["violin", "guitar", "tambour", "battery", "trumpet"];
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
    
    func createBlocks() {
        var block = UIButton(frame: CGRectMake(10, 10, 30, 30))
        viewForBlocks .addSubview(block)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return instrumentsList.count;
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return instrumentsList[row];
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        instrumentsB.titleLabel?.text = instrumentsList[row]
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
    }
    
    @IBAction func StopButtonTouched(sender: AnyObject) {
        println("stop");
    }
    
    @IBAction func PlayButtonTouched(sender: AnyObject) {
        println("play");
    }
    
}

