//
//  SidebarVC.swift
//  Orphee
//
//  Created by JohnBob on 04/03/2015.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit

class SidebarVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    /// The view containing the sidebar's PickerView.
    @IBOutlet weak var viewForPicker: UIView!

    /// The sidebar's `Save` button.
    @IBOutlet weak var saveB: UIButton!

    /// The sidebar's `Import` button.
    @IBOutlet weak var importB: UIButton!

    /// The sidebar's `Instruments` button.
    @IBOutlet weak var instrumentsB: UIButton!

    /// The sidebar's PickerView.
    @IBOutlet weak var pickerInstruments: UIPickerView!

    /// A list of all instruments supported by the app. TODO: actually implement the system.
    var instrumentsList: [String] = [];

    /// The index of the selected instrument. Updates the `Instruments` button displayed text when set.
    var currentInstrument: Int = 0 {
        didSet {
            instrumentsB.setTitle(instrumentsList[currentInstrument], forState: UIControlState.Normal);
        }
    }

    /// MARK: Overrides
    //

    /// Called when this controller's view is loaded.
    override func viewDidLoad() {

        super.viewDidLoad();

        instrumentsList = ["violin", "guitar", "tambour", "battery", "trumpet"];
        layoutButtons();
    }

    /// Called when this controller's view is displayed.
    override func viewDidAppear(animated: Bool) {

        super.viewDidAppear(animated);

        println("view appears");
    }

    /// Called when the app consumes too much memory.
    /// Dispose of any resources that can be recreated.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    /// MARK: UIPickerViewDataSource protocol
    //

    /// Called by the picker view when it needs the number of components.
    ///
    /// :param: pickerView  An object representing the picker view requesting the data.
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1;
    }

    /// Called by the picker view when it needs the number of rows for a specified component.
    ///
    /// :param: pickerView  An object representing the picker view requesting the data.
    /// :param: component   A zero-indexed number identifying a component of pickerView.
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return instrumentsList.count;
    }

    /// MARK: UIPickerViewDelegate protocol
    //

    /// Called by the picker view when it needs the title to use for a given row in a given component.
    ///
    /// :param: pickerView  An object representing the picker view requesting the data.
    /// :param: row         A zero-indexed number identifying a row of component.
    /// :param: component   A zero-indexed number identifying a component of pickerView.
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return instrumentsList[row];
    }

    /// Called by the picker view when the user selects a row in a component.
    ///
    /// :param: pickerView  An object representing the picker view requesting the data.
    /// :param: row         A zero-indexed number identifying a row of component.
    /// :param: component   A zero-indexed number identifying a component of pickerView.
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        currentInstrument = row;
        println("chosen instrument : \(instrumentsList[row])");
    }

    /// MARK: UI action responders
    //

    /// Called when the UI's `Save` button is pressed.
    /// Displays *save*
    ///
    /// :param: sender  The object sending the event.
    @IBAction func saveButtonTouched(sender: AnyObject) {
        println("save");
    }

    /// Called when the UI's `Import` button is pressed.
    /// Displays *import*
    ///
    /// :param: sender  The object sending the event.
    @IBAction func importButtonTouched(sender: AnyObject) {
        println("import");
    }

    /// Called when the PickerView's `Close` button is pressed.
    /// Closes the PickerView.
    ///
    /// :param: sender  The object sending the event.
    @IBAction func closeViewForPicker(sender: AnyObject) {

        viewForPicker.hidden = true;
    }

    /// Called when the UI's `Instruments` button is pressed.
    /// Reveals the PickerView.
    ///
    /// :param: sender  The object sending the event.
    @IBAction func instrumentsButtonTouched(sender: AnyObject) {

        viewForPicker.hidden = false;
        currentInstrument = Int(currentInstrument);
    }

    /// MARK: Utility methods
    //

    /// Defines the controlled buttons' appearance.
    func layoutButtons() {

        saveB.layer.cornerRadius = 8;
        saveB.layer.borderWidth = 1;
        importB.layer.cornerRadius = 8;
        importB.layer.borderWidth = 1;
        instrumentsB.layer.cornerRadius = 8;
        instrumentsB.layer.borderWidth = 1;
    }
}