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
    @IBOutlet weak var scrollBlocks: UIScrollView!
    var dictBlocks: [String:[UIButton]] = [:];
    var instrumentsList: [String] = [];
    override func viewDidLoad() {
        super.viewDidLoad();
        instrumentsList = ["violin", "guitar", "tambour", "battery", "trumpet"];
        layoutButtons();
        createBlocks(10, column: instrumentsList.count);
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
    
    func createBlocks(lines: Int, column: Int) {
        var posX = 0;
        var posY = 20;
        var width = 50;
        var height = 50;
        
        for (var j = 0; j < column; j++) {
            posX = 40;
            var array: [UIButton] = [];
            for (var i = 0; i < lines; i++) {
                var block = UIButton(frame: CGRectMake(CGFloat(posX), CGFloat(posY), CGFloat(width), CGFloat(height)));
                block.backgroundColor = UIColor.blueColor();
                scrollBlocks .addSubview(block);
                array.append(block);
                posX += width + 10;
            }
            posY += height + 10;
            dictBlocks[instrumentsList[j]] = array;
        }
        scrollBlocks.contentSize = CGSizeMake(CGFloat(posX), CGFloat(posY));
    }
    
    @IBAction func addColumOfBlocks(sender: AnyObject) {
        var posX: CGFloat = 0;
        var posY: CGFloat = 0;
        var posWidth: CGFloat = 0;
        for (var i = 0; i < instrumentsList.count; i++) {
            var pos = dictBlocks[instrumentsList[i]]?.last?.frame;
            posX = pos!.origin.x + pos!.width + 10;
            posY = pos!.origin.y;
            posWidth = pos!.size.width;
            
            var block = UIButton(frame: CGRectMake(posX, posY, pos!.width, pos!.height));
            block.backgroundColor = UIColor.redColor();
            scrollBlocks .addSubview(block);
            dictBlocks[instrumentsList[i]]?.append(block);
        }
        scrollBlocks.contentSize = CGSizeMake(posX + posWidth, scrollBlocks.frame.height);
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

