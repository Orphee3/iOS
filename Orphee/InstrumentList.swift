//
//  InstrumentList.swift
//  Orphee
//
//  Created by JohnBob on 06/03/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit

class InstrumentList: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    var currentInstrument: String = "";
    var instrumentsList: [Int:(name: String, cords: Int)] = [
        0 : ("violin", 12),
        1 : ("guitar", 12),
        2 : ("tambour", 4),
        3 : ("battery", 8),
        4 : ("trumpet", 12)
    ];

    /**
    *** PickerViewDataSource
    **/
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1;
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return instrumentsList.count;
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        let instrument = self.instrumentsList[row];
        return instrument?.name;
    }

    /**
    *** PickerViewDelegate
    **/
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let instrument = self.instrumentsList[row];

        self.currentInstrument = instrument!.name;
        println("chosen instrument : \(instrumentsList[row])");
    }
}
