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

    var dictBlocks: [Int:UITimeBlockArray] = [:];
    var instrumentsList: [String:Int] = [
        "violin" : 12,
        "guitar" : 12,
        "tambour" : 4,
        "battery" : 8,
        "trumpet" : 12
    ];

    override func viewDidLoad() {
        super.viewDidLoad();

        createBlocks(10);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createBlocks(columns: Int) {

        var size: (x: Int, y: Int) = (0, 0);
        for (instrument, cord) in instrumentsList {
            
            var track: UITimeBlockArray = UITimeBlockArray(count: columns, rowNbr: cord, color: UIColor.blueColor());

            dictBlocks[cord] = track;
            scrollBlocks.addSubview(track);
            size = track.endPos;
        }
        scrollBlocks.contentSize = CGSizeMake(CGFloat(size.x), CGFloat(size.y));
    }

    @IBAction func addColumOfBlocks(sender: AnyObject) {

        var size: (x: Int, y: Int) = (0, 0);
        for (instrument, track) in dictBlocks {

            track.addButtons(4, color: UIColor.redColor());
            size = track.endPos;
        }
        scrollBlocks.contentSize = CGSizeMake(CGFloat(size.x), CGFloat(size.y));
    }

    @IBAction func removeColumOfBlocks(sender: AnyObject) {

        for (instrument, track) in dictBlocks {

            track.removeButtons(4);
        }
    }

    @IBAction func StopButtonTouched(sender: AnyObject) {
        println("stop");
    }
    
    @IBAction func PlayButtonTouched(sender: AnyObject) {
        println("play");
    }
}

