//
//  ViewController.swift
//  Orphee
//
//  Created by John Bob on 29/01/15.
//  Copyright (c) 2015 __ORPHEE__. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var scrollBlocks: UIScrollView!

    var dictBlocks: [String:UITimeBlockArray] = [:];

    var instrumentsList: [String] = ["violin", "guitar", "tambour", "battery", "trumpet"];

    override func viewDidLoad() {
        super.viewDidLoad();

        createBlocks(10);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    @IBAction func addColumOfBlocks(sender: AnyObject) {

        for (instrument, track) in dictBlocks {

            track.addButtons(4, color: UIColor.redColor(), toView: scrollBlocks);
            scrollBlocks.contentSize = CGSizeMake(CGFloat(track.endPos.x), CGFloat(track.endPos.y));
        }
    }

    @IBAction func StopButtonTouched(sender: AnyObject) {
        println("stop");
    }
    
    @IBAction func PlayButtonTouched(sender: AnyObject) {
        println("play");
    }
    func createBlocks(columns: Int) {

        for (idx, instrument) in enumerate(instrumentsList) {

            var track: UITimeBlockArray = UITimeBlockArray(rowNbr: idx);

            dictBlocks[instrument] = track;
            track.addButtons(columns, color: UIColor.blueColor(), toView: scrollBlocks)
            scrollBlocks.contentSize = CGSizeMake(CGFloat(track.endPos.x), CGFloat(track.endPos.y));
        }
    }
}

